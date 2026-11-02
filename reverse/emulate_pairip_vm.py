#!/usr/bin/env python3
"""Experimental host-side execution of PairIP's ARM64 native VM with Unicorn.

This drives the JNI native executeVM entry directly, supplies an asset as a fake
jbyteArray, and stubs the small JNI/libc surface needed during decoding. It is a
diagnostic tool, not yet a complete Android/JNI emulator.
"""
from __future__ import annotations

import argparse
import collections
import hashlib
import math
import re
import struct
from pathlib import Path

from elftools.elf.elffile import ELFFile
from unicorn import (
    Uc, UcError, UC_ARCH_ARM64, UC_MODE_ARM, UC_PROT_ALL,
    UC_HOOK_CODE, UC_HOOK_MEM_INVALID, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE,
    UC_HOOK_INTR,
)
from unicorn.arm64_const import *

PAGE = 0x1000
def up(value: int) -> int:
    return (value + PAGE - 1) & -PAGE

parser = argparse.ArgumentParser()
parser.add_argument("asset", type=Path)
parser.add_argument("--library", type=Path, default=Path("reverse/build/v18/libpairipcore.so"))
parser.add_argument("--target-library", type=Path)
parser.add_argument("--target-base", type=lambda value: int(value, 0), default=0x1000_0000)
parser.add_argument("--presented-native-base", type=lambda value: int(value, 0), default=0,
                    help="nonzero PairIP ELF alias reported consistently through procfs and dl_iterate_phdr")
parser.add_argument("--actual-entry", action="store_true",
                    help="run JNI_OnLoad and the exported DT_INIT ExecuteProgram path")
parser.add_argument("--dt-init-argument", type=lambda value: int(value, 0), default=None,
                    help="override the libil2cpp base passed by its real DT_INIT; 0 reproduces the old incorrect null-argument control")
parser.add_argument("--with-startup", action="store_true",
                    help="execute ERz before AYum in the same initialized process")
parser.add_argument("--startup-stack", choices=("short", "framework", "framework-core"),
                    default="short", help="Java stack profile supplied during ERz")
parser.add_argument("--proc-profile", choices=("synthetic", "v11"), default="synthetic",
                    help="procfs inputs; v11 reconstructs the captured device tombstone")
parser.add_argument("--property-profile", choices=("empty", "physical-arm64", "v11"), default="empty",
                    help="__system_property_foreach inputs; v11 uses values captured on the device")
parser.add_argument("--clock-profile", choices=("constant", "monotonic"), default="constant",
                    help="clock_gettime input; monotonic advances deterministically by 1 ms per call")
parser.add_argument("--emulate-original-tls", action="store_true",
                    help="hook the original helper with per-thread TLS semantics")
parser.add_argument("--max-insns", type=int, default=200_000_000)
args = parser.parse_args()
asset = args.asset.read_bytes()
proc_status_override = b""
proc_maps_override = b""
emulated_pid = 1
if args.proc_profile == "v11":
    proc_status_override = Path("reverse/v11-results/proc-status.txt").read_bytes()
    proc_maps_override = Path("reverse/v11-results/proc-maps.txt").read_bytes()
    emulated_pid = 4286
    print(f"Using captured v11 proc profile: {proc_maps_override.count(bytes([10]))} map lines")
next_fake_child_pid = emulated_pid + 1
fake_child_pids: set[int] = set()
clock_ticks = 0
dumpable_state = 1
app_dir = "/data/app/com.Ovilex.BusSimulator2023"
if args.proc_profile == "v11":
    app_dir = ("/data/app/~~6kGyZ3ZfyCC3zfV8QVIrOg==/"
               "com.Ovilex.BusSimulator2023-c5fSgbiyHTXH7OeU7PsabA==")

system_properties: dict[str, str] = {}
if args.property_profile == "physical-arm64":
    system_properties = {
        "ro.product.cpu.abilist": "arm64-v8a",
        "ro.dalvik.vm.native.bridge": "",
        "ro.build.version.sdk": "35",
    }
elif args.property_profile == "v11":
    # Values preserved in reverse/v11-results/runtime.zip/status.json.
    system_properties = {
        "ro.product.cpu.abilist": "x86_64,arm64-v8a",
        "ro.dalvik.vm.native.bridge": "libndk_translation.so",
        "ro.build.version.sdk": "35",
    }
print(f"Using property profile {args.property_profile}: {system_properties}")

uc = Uc(UC_ARCH_ARM64, UC_MODE_ARM)
with args.library.open("rb") as stream:
    elf = ELFFile(stream)
    loads = [segment for segment in elf.iter_segments() if segment["p_type"] == "PT_LOAD"]
    load_images = [(segment, segment.data()) for segment in loads]
    image_end = max(segment["p_vaddr"] + segment["p_memsz"] for segment in loads)
    uc.mem_map(0, up(image_end), UC_PROT_ALL)
    for segment, image in load_images:
        uc.mem_write(segment["p_vaddr"], image)
    # The Android loader applies these before any C++ vtable is used. This ELF
    # is mapped at emulated base zero, so each RELATIVE slot equals its addend.
    relative_relocations = []
    for section in elf.iter_sections():
        if section["sh_type"] not in ("SHT_RELA", "SHT_REL"):
            continue
        for relocation in section.iter_relocations():
            if relocation["r_info_type"] == 1027:  # R_AARCH64_RELATIVE
                relative_relocations.append((relocation["r_offset"], relocation["r_addend"]))
                uc.mem_write(relocation["r_offset"], struct.pack("<Q", relocation["r_addend"]))

native_view_base = args.presented_native_base
if native_view_base:
    # Keep the instrumented instruction addresses at zero, but provide the
    # realistic nonzero ELF image that Android introspection would observe.
    uc.mem_map(native_view_base, up(image_end), UC_PROT_ALL)
    for segment, image in load_images:
        uc.mem_write(native_view_base + segment["p_vaddr"], image)
    for offset, addend in relative_relocations:
        uc.mem_write(native_view_base + offset,
                     struct.pack("<Q", native_view_base + addend))
    print(f"Presenting PairIP ELF alias at {native_view_base:#x}")

# Native AYum initialization inspects and transforms the game's IL2CPP image.
# Model it as a second Android-loaded ELF instead of leaving its addresses absent.
target_map_lines = bytearray()
if args.target_library:
    with args.target_library.open("rb") as stream:
        target_elf = ELFFile(stream)
        target_loads = [segment for segment in target_elf.iter_segments()
                        if segment["p_type"] == "PT_LOAD"]
        target_end = max(segment["p_vaddr"] + segment["p_memsz"]
                         for segment in target_loads)
        uc.mem_map(args.target_base, up(target_end), UC_PROT_ALL)
        for segment in target_loads:
            uc.mem_write(args.target_base + segment["p_vaddr"], segment.data())
            flags = segment["p_flags"]
            permissions = ("r" if flags & 4 else "-") + ("w" if flags & 2 else "-") + ("x" if flags & 1 else "-") + "p"
            map_start = args.target_base + (segment["p_vaddr"] & -PAGE)
            map_end = args.target_base + up(segment["p_vaddr"] + segment["p_memsz"])
            file_offset = segment["p_offset"] & -PAGE
            target_map_lines.extend(
                f"{map_start:08x}-{map_end:08x} {permissions} {file_offset:08x} 00:00 0 "
                f"{app_dir}/lib/arm64/{args.target_library.name}\n".encode()
            )
        for section in target_elf.iter_sections():
            if section["sh_type"] not in ("SHT_RELA", "SHT_REL"):
                continue
            for relocation in section.iter_relocations():
                if relocation["r_info_type"] == 1027:  # R_AARCH64_RELATIVE
                    uc.mem_write(args.target_base + relocation["r_offset"],
                                 struct.pack("<Q", args.target_base + relocation["r_addend"]))
        print(f"Loaded target {args.target_library} at {args.target_base:#x}, "
              f"image end {args.target_base + target_end:#x}")

target_runtime_visible = not args.with_startup

ENV = 0x2000_0000
VTABLE = 0x2001_0000
BYTE_ARRAY = 0x2002_0000
OBJECT_ARRAY = 0x2002_1000
FAKE_FN = 0x2100_0000
FAKE_SYMBOL = 0x2200_0000
HEAP = 0x3000_0000
STACK = 0x4000_0000
SENTINEL = 0x5000_0000
WORKER_SENTINEL = 0x5000_1000
DL_CALLBACK_SENTINEL = 0x5000_2000
PTHREAD_ONCE_SENTINEL = 0x5000_3000
PROPERTY_CALLBACK_SENTINEL = 0x5000_4000
PROPERTY_READ_CALLBACK_SENTINEL = 0x5000_5000
uc.mem_map(ENV, 0x30000, UC_PROT_ALL)
uc.mem_map(FAKE_FN, 0x10000, UC_PROT_ALL)
uc.mem_map(FAKE_SYMBOL, 0x10000, UC_PROT_ALL)
uc.mem_map(HEAP, 0x0800_0000, UC_PROT_ALL)
uc.mem_map(STACK, 0x0020_0000, UC_PROT_ALL)
uc.mem_map(SENTINEL, 6 * PAGE, UC_PROT_ALL)
uc.mem_write(ENV, struct.pack("<Q", VTABLE))
# The patched TLS resolver maps metadata 0x982e8 and 0x98308 to these
# process-local slots. JNI_OnLoad normally seeds them with "attached" and JNIEnv.
uc.mem_write(0x99430, b"\x01")
uc.mem_write(0x99440, struct.pack("<Q", ENV))
for index in range(256):
    uc.mem_write(VTABLE + index * 8, struct.pack("<Q", FAKE_FN + index * 0x100))

heap_next = HEAP
allocations: dict[int, int] = {}
fake_symbols: dict[bytes, int] = {}
virtual_files: dict[int, tuple[str, bytes, int]] = {}
virtual_directories: dict[int, list[tuple[str, int]]] = {}
virtual_dir_offsets: dict[int, int] = {}
java_classes: dict[bytes, int] = {}
java_strings: dict[int, bytes] = {}
java_arrays: dict[int, list[int]] = {}
java_byte_arrays: dict[int, tuple[int, int]] = {}
java_methods: dict[tuple[int, bytes, bytes], int] = {}
java_method_info: dict[int, tuple[int, bytes, bytes]] = {}
java_field_info: dict[int, tuple[int, bytes, bytes]] = {}
java_objects: dict[int, dict[str, object]] = {}
java_context = 0
next_virtual_fd = 3

def virtual_file_contents(path: str) -> bytes:
    if path == "/proc/self/status" and proc_status_override:
        return proc_status_override
    if path == "/proc/self/maps" and proc_maps_override:
        return proc_maps_override
    if path == "/proc/self/status":
        return (b"Name:\tpairip-vm\nState:\tR (running)\nPid:\t1\nTgid:\t1\n"
                b"TracerPid:\t0\nUid:\t10000\t10000\t10000\t10000\n"
                b"Gid:\t10000\t10000\t10000\t10000\n")
    if path == "/proc/self/maps":
        # The emulator maps the ELF at zero. Keep the synthetic map consistent
        # with that address space instead of leaking unrelated host mappings.
        return ((bytes(target_map_lines) if target_runtime_visible else b"") +
                f"{native_view_base:08x}-{native_view_base + up(image_end):08x} r-xp 00000000 00:00 0 ".encode() +
                app_dir.encode() + b"/lib/arm64/libpairipcore.so\n"
                b"20000000-20030000 rw-p 00000000 00:00 0 [anonymous]\n"
                b"30000000-38000000 rw-p 00000000 00:00 0 [anonymous]\n"
                b"40000000-40200000 rw-p 00000000 00:00 0 [stack]\n")
    if path == "/dev/urandom":
        return hashlib.sha256(b"pairip-vm-urandom").digest() * 32
    return b""


def virtual_directory_entries(path: str) -> list[tuple[str, int]]:
    if path != "/proc/self/map_files/":
        return [(".", 4), ("..", 4)]
    entries = [(".", 4), ("..", 4)]
    for line in virtual_file_contents("/proc/self/maps").decode().splitlines():
        columns = line.split()
        if len(columns) >= 6 and columns[-1].startswith("/"):
            entries.append((columns[0], 10))  # DT_LNK
    return entries


def virtual_map_link(range_name: str) -> bytes:
    for line in virtual_file_contents("/proc/self/maps").decode().splitlines():
        columns = line.split()
        if len(columns) >= 6 and columns[0] == range_name:
            return columns[-1].encode()
    return b""


def alloc(size: int, alignment: int = 16) -> int:
    global heap_next
    size = max(int(size), 1)
    address = (heap_next + alignment - 1) & -alignment
    heap_next = address + up(size)
    if heap_next >= HEAP + 0x0800_0000:
        raise MemoryError("fake heap exhausted")
    allocations[address] = size
    return address

# PLT addresses from this exact libpairipcore build.
PLT = {
    0x8DCE0: "dlsym",
    0x8DCF0: "dl_iterate_phdr",
    0x8DD00: "dlclose",
    0x8DD10: "dlerror",
    0x8DD20: "dlopen",
    0x8DD30: "realloc",
    0x8DD40: "pthread_mutex_unlock",
    0x8DD70: "pthread_cond_signal",
    0x8DD80: "memmove",
    0x8DDA0: "strlen",
    0x8DDB0: "free",
    0x8DDC0: "malloc",
    0x8DDD0: "pthread_once",
    0x8DDE0: "strncmp",
    0x8DDF0: "fprintf",
    0x8DE00: "stack_chk_fail",
    0x8DE10: "memcmp",
    0x8DE30: "pthread_getspecific",
    0x8DE50: "pthread_setspecific",
    0x8DE80: "pthread_join",
    0x8DE90: "pthread_create",
    0x8DEB0: "pthread_key_delete",
    0x8DEF0: "pthread_cond_wait",
    0x8DF00: "pthread_detach",
    0x8DED0: "syscall",
    0x8DF10: "strcmp",
    0x8DF20: "pthread_mutex_lock",
    0x8DF50: "memcpy",
    0x8DF70: "getauxval",
    0x8DF80: "abort",
    0x8DFA0: "system_property_read",
    0x8DFB0: "calloc",
    0x8DFC0: "memchr",
    0x8DFE0: "snprintf",
    0x8DFF0: "strtoull",
    0x8E000: "getpid",
    0x8E010: "posix_memalign",
    0x8E020: "pthread_key_create",
    0x8E030: "system_property_foreach",
    0x8E050: "errno_location",
    0x8E060: "pthread_cond_broadcast",
    0x8E0A0: "memset",
    0x8E0D0: "getpagesize",
    0x8E0E0: "fmodf",
    0x8E0F0: "fmod",
}
trace = collections.deque(maxlen=400)
last_vm_dispatch_insn = 0
active_opcode_trace: list[int] | None = None
active_opcode_name = ""
insn_count = 0
vm_steps = 0
vm_base = None
vm_length = None
current_vm_pc = None
current_opcode = -1
current_thread = "main"
main_context = None
worker_context = None
main_resume_pc = 0
worker_resume_pc = 0
thread_switches = 0
original_tls_slots: dict[tuple[str, int], int] = {}
pthread_key_values: dict[tuple[str, int], int] = {}
pthread_key_destructors: dict[int, int] = {}
next_pthread_key = 1
pthread_once_return_pc = 0
target_reads = 0
target_writes = 0
dl_callback = 0
dl_callback_data = 0
dl_return_pc = 0
dl_module_index = 0
dl_modules: list[str] = []
property_callback = 0
property_callback_data = 0
property_return_pc = 0
property_read_return_pc = 0
property_index = 0
property_infos: list[int] = []
property_values: dict[int, tuple[bytes, bytes]] = {}
errno_address = 0

rare_call_counts: collections.Counter[str] = collections.Counter()


def rare_call_log(name: str, detail: str) -> None:
    rare_call_counts[name] += 1
    if rare_call_counts[name] <= 40:
        print(f"RARE_CALL {name} {detail} vm_steps={vm_steps} insns={insn_count}")


# JNI indices from JNINativeInterface.
def return_to_lr() -> None:
    uc.reg_write(UC_ARM64_REG_PC, uc.reg_read(UC_ARM64_REG_X30))

def cstring(address: int, limit: int = 0x10000) -> bytes:
    result = bytearray()
    for offset in range(limit):
        value = uc.mem_read(address + offset, 1)[0]
        if value == 0:
            return bytes(result)
        result.append(value)
    raise RuntimeError(f"unterminated string at {address:#x}")

def new_java_handle() -> int:
    handle = alloc(16)
    uc.mem_write(handle, bytes(16))
    return handle


def new_java_string(value: bytes) -> int:
    handle = new_java_handle()
    java_strings[handle] = value
    return handle


def read_va_list_args(address: int, count: int) -> list[int]:
    stack, gr_top, _vr_top = struct.unpack("<QQQ", bytes(uc.mem_read(address, 24)))
    gr_offset = struct.unpack("<i", bytes(uc.mem_read(address + 24, 4)))[0]
    result = []
    for _ in range(count):
        if gr_offset <= -8:
            slot = gr_top + gr_offset
            gr_offset += 8
        else:
            slot = stack
            stack += 8
        result.append(struct.unpack("<Q", bytes(uc.mem_read(slot, 8)))[0])
    return result


def read_instance_call_args(index: int, first: int, count: int) -> list[int]:
    mode = (index - 34) % 3  # direct, va_list, jvalue[] for JNI instance calls
    if mode == 1:
        return read_va_list_args(first, count)
    if mode == 2:
        return [struct.unpack("<Q", bytes(uc.mem_read(first + offset * 8, 8)))[0]
                for offset in range(count)] if first else []
    return [uc.reg_read(UC_ARM64_REG_X3 + offset) for offset in range(count)]


def dump_telemetry_memory() -> None:
    output = Path(f"/home/user/.cache/bus-recovery/telemetry-memory-{vm_steps}")
    output.mkdir(parents=True, exist_ok=True)
    keywords = (b"debug", b"trace", b"emulat", b"integrity", b"error", b"fail",
                b"success", b"root", b"proc", b"maps", b"vm", b"exception",
                b"pairip", b"report", b"detect", b"status")
    interesting = []
    regions_text = []
    for number, (start, end, permissions) in enumerate(uc.mem_regions()):
        size = end - start + 1
        regions_text.append(f"{number}\t{start:#x}\t{end:#x}\t{size:#x}\t{permissions}")
        if not permissions & 2 or size > 160 * 1024 * 1024:
            continue
        data = bytes(uc.mem_read(start, size))
        (output / f"region-{number:02d}-{start:x}.bin").write_bytes(data)
        for match in re.finditer(rb"[\x20-\x7e]{5,}", data):
            text = match.group()
            lowered = text.lower()
            if any(keyword in lowered for keyword in keywords):
                interesting.append(f"{start + match.start():#x}\t{text[:2000].decode(errors='replace')}")
    (output / "regions.tsv").write_text("\n".join(regions_text) + "\n")
    allocation_lines = []
    for address, size in sorted(allocations.items()):
        preview = bytes(uc.mem_read(address, min(size, 96)))
        allocation_lines.append(f"{address:#x}\t{size}\t{preview.hex()}\t{preview!r}")
    (output / "allocations.tsv").write_text("\n".join(allocation_lines) + "\n")
    (output / "interesting.txt").write_text("\n".join(interesting) + "\n")
    print(f"Telemetry memory dump: {output} writable_regions={len(list(output.glob('region-*.bin')))} "
          f"interesting_strings={len(interesting)}")


def handle_jni(index: int) -> None:
    global java_context
    x1 = uc.reg_read(UC_ARM64_REG_X1)
    x2 = uc.reg_read(UC_ARM64_REG_X2)
    x3 = uc.reg_read(UC_ARM64_REG_X3)
    if index == 4:  # GetVersion
        uc.reg_write(UC_ARM64_REG_X0, 0x10006)
    elif index == 6:  # FindClass
        name = cstring(x1)
        if name not in java_classes:
            java_classes[name] = new_java_handle()
        print(f"JNI FindClass {name.decode(errors='replace')!r}")
        uc.reg_write(UC_ARM64_REG_X0, java_classes[name])
    elif index == 14:  # ThrowNew
        print(f"JNI ThrowNew {cstring(x2).decode(errors='replace')!r}")
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif index == 24:  # IsSameObject
        uc.reg_write(UC_ARM64_REG_X0, int(x1 == x2))
    elif index in (28, 29, 30):  # NewObject[VA]
        method_info = java_method_info.get(x2, (x1, b"<init>", b"()V"))
        argument_count = 0 if method_info[2].startswith(b"()") else 1
        if index == 29 and argument_count:
            arguments = read_va_list_args(x3, argument_count)
        elif index == 30 and argument_count:
            arguments = [struct.unpack("<Q", bytes(uc.mem_read(x3 + offset * 8, 8)))[0]
                         for offset in range(argument_count)] if x3 else []
        elif index == 28 and argument_count:
            arguments = [x3]
        else:
            arguments = []
        handle = new_java_handle()
        java_objects[handle] = {"class": x1, "constructor": method_info[1], "args": arguments}
        if x1 == java_classes.get(b"java/lang/Long"):
            print(f"JNI NewLong handle={handle:#x} args={[hex(value) for value in arguments]}")
        uc.reg_write(UC_ARM64_REG_X0, handle)
    elif index in (34, 35, 36):  # CallObjectMethod[VA]
        method_info = java_method_info.get(x2)
        if method_info and method_info[1] in (b"getResource", b"getStackTrace", b"toString"):
            instance = java_objects.get(x1, {})
            print(f"JNI CallObjectMethod {method_info[1].decode(errors='replace')} "
                  f"object={x1:#x} instance={instance}")
        if method_info and method_info[1] == b"getResource":
            result = new_java_handle()
            java_objects[result] = {
                "class": java_classes.get(b"java/net/URL", 0),
                "url": f"jar:file:{app_dir}/base.apk!/AndroidManifest.xml".encode(),
            }
        elif method_info and method_info[1] == b"getStackTrace":
            result = new_java_handle()
            frames = []
            frame_specs = [
                (b"com.pairip.VMRunner", b"executeVM", b"Native Method",
                 b"VMRunner.java", -2, True),
                (b"com.pairip.VMRunner", b"invoke", b"VMRunner.java:49",
                 b"VMRunner.java", 49, False),
            ]
            if (args.with_startup and not target_runtime_visible
                    and args.startup_stack != "short"):
                frame_specs.append(
                    (b"com.pairip.StartupLauncher", b"launch", b"StartupLauncher.java:14",
                     b"StartupLauncher.java", 14, False))
                if args.startup_stack == "framework-core":
                    # First ERz call: CoreComponentFactory is initialized while
                    # LoadedApk creates its class loader. SafeDKApplication's
                    # later launch() call returns through launchCalled.
                    frame_specs.extend([
                        (b"androidx.core.app.CoreComponentFactory", b"<clinit>",
                         b"CoreComponentFactory.java", b"CoreComponentFactory.java", -1, False),
                        (b"java.lang.Class", b"newInstance", b"Native Method",
                         b"Class.java", -2, True),
                        (b"android.app.LoadedApk", b"createAppFactory",
                         b"LoadedApk.java:272", b"LoadedApk.java", 272, False),
                        (b"android.app.LoadedApk", b"createOrUpdateClassLoaderLocked",
                         b"LoadedApk.java:1043", b"LoadedApk.java", 1043, False),
                        (b"android.app.LoadedApk", b"getClassLoader",
                         b"LoadedApk.java:1134", b"LoadedApk.java", 1134, False),
                        (b"android.app.LoadedApk", b"getResources",
                         b"LoadedApk.java:1382", b"LoadedApk.java", 1382, False),
                        (b"android.app.ContextImpl", b"createAppContext",
                         b"ContextImpl.java:3402", b"ContextImpl.java", 3402, False),
                        (b"android.app.ContextImpl", b"createAppContext",
                         b"ContextImpl.java:3393", b"ContextImpl.java", 3393, False),
                        (b"android.app.ActivityThread", b"handleBindApplication",
                         b"ActivityThread.java:7381", b"ActivityThread.java", 7381, False),
                    ])
                else:
                    # Control profile for the default AppComponentFactory route.
                    frame_specs.extend([
                        (b"com.safedk.android.SafeDKApplication", b"<clinit>", b"SourceFile",
                         b"SourceFile", -1, False),
                        (b"java.lang.Class", b"newInstance", b"Native Method",
                         b"Class.java", -2, True),
                        (b"android.app.AppComponentFactory", b"instantiateApplication",
                         b"AppComponentFactory.java:76", b"AppComponentFactory.java", 76, False),
                        (b"android.app.Instrumentation", b"newApplication",
                         b"Instrumentation.java:1352", b"Instrumentation.java", 1352, False),
                        (b"android.app.LoadedApk", b"makeApplicationInner",
                         b"LoadedApk.java:1471", b"LoadedApk.java", 1471, False),
                        (b"android.app.LoadedApk", b"makeApplicationInner",
                         b"LoadedApk.java:1403", b"LoadedApk.java", 1403, False),
                        (b"android.app.ActivityThread", b"handleBindApplication",
                         b"ActivityThread.java:7464", b"ActivityThread.java", 7464, False),
                    ])
                frame_specs.extend([
                    (b"android.app.ActivityThread", b"-$$Nest$mhandleBindApplication",
                     b"Unknown Source:0", b"", 0, False),
                    (b"android.app.ActivityThread$H", b"handleMessage",
                     b"ActivityThread.java:2416", b"ActivityThread.java", 2416, False),
                    (b"android.os.Handler", b"dispatchMessage", b"Handler.java:107",
                     b"Handler.java", 107, False),
                    (b"android.os.Looper", b"loopOnce", b"Looper.java:232",
                     b"Looper.java", 232, False),
                    (b"android.os.Looper", b"loop", b"Looper.java:317",
                     b"Looper.java", 317, False),
                    (b"android.app.ActivityThread", b"main", b"ActivityThread.java:8705",
                     b"ActivityThread.java", 8705, False),
                    (b"java.lang.reflect.Method", b"invoke", b"Native Method",
                     b"Method.java", -2, True),
                    (b"com.android.internal.os.RuntimeInit$MethodAndArgsCaller", b"run",
                     b"RuntimeInit.java:580", b"RuntimeInit.java", 580, False),
                    (b"com.android.internal.os.ZygoteInit", b"main", b"ZygoteInit.java:886",
                     b"ZygoteInit.java", 886, False),
                ])
            for class_name, method_name, location, file_name, line, native in frame_specs:
                frame = new_java_handle()
                java_objects[frame] = {
                    "class": java_classes.get(b"java/lang/StackTraceElement", 0),
                    "class_name": class_name, "method_name": method_name,
                    "location": location, "file_name": file_name,
                    "line": line, "native": native,
                }
                frames.append(frame)
            java_arrays[result] = frames
        elif method_info and method_info[1] == b"substring" and x1 in java_strings:
            start, end = read_instance_call_args(index, x3, 2)
            result = new_java_string(java_strings[x1][start:end])
        elif method_info and method_info[1] in (
            b"getClassName", b"getMethodName", b"getFileName",
        ):
            instance = java_objects.get(x1, {})
            key = {
                b"getClassName": "class_name", b"getMethodName": "method_name",
                b"getFileName": "file_name",
            }[method_info[1]]
            result = new_java_string(instance.get(key, b"")) if key in instance else 0
        elif method_info and method_info[1] == b"toString":
            instance = java_objects.get(x1, {})
            if "method_name" in instance:
                location = instance.get("location")
                if location is None:
                    location = (b"Native Method" if instance.get("native") else
                                instance.get("file_name", b"") + b":" + str(instance.get("line", 0)).encode())
                result = new_java_string(
                    instance.get("class_name", b"") + b"." + instance.get("method_name", b"") +
                    b"(" + location + b")"
                )
            elif "url" in instance:
                result = new_java_string(instance["url"])
            else:
                result = 0
        elif method_info and method_info[1] in (
            b"setPackage", b"putExtra", b"setFlags", b"setData",
        ):
            instance = java_objects.setdefault(x1, {"class": java_classes.get(b"android/content/Intent", 0)})
            if method_info[1] == b"putExtra":
                key_handle, value = read_instance_call_args(index, x3, 2)
                key = java_strings.get(key_handle, b"<non-string>")
                signature = method_info[2]
                extras = instance.setdefault("extras", {})
                if signature.endswith(b"I)Landroid/content/Intent;"):
                    signed_value = value & 0xFFFFFFFF
                    if signed_value & 0x80000000:
                        signed_value -= 0x100000000
                    extras[key] = signed_value
                    print(f"JNI Intent.putExtra {key.decode(errors='replace')!r}={signed_value} ({value:#x})")
                elif signature.endswith(b"Ljava/lang/CharSequence;)Landroid/content/Intent;"):
                    text = java_strings.get(value, b"")
                    extras[key] = text
                    print(f"JNI Intent.putExtra {key.decode(errors='replace')!r}={text[:8000]!r}")
                elif signature.endswith(b"[B)Landroid/content/Intent;"):
                    data, length = java_byte_arrays.get(value, (0, 0))
                    payload = bytes(uc.mem_read(data, length)) if data else b""
                    extras[key] = payload
                    print(f"JNI Intent.putExtra {key.decode(errors='replace')!r}=byte[{len(payload)}] "
                          f"hex={payload[:512].hex()}")
                    if payload and sum(byte in b"\t\n\r" or 32 <= byte < 127 for byte in payload) / len(payload) > 0.9:
                        print(f"JNI Intent payload text={payload[:16000].decode(errors='replace')}")
                    if payload:
                        output = Path(f"reverse/logs/telemetry-payload-{vm_steps}-{len(payload)}.bin")
                        output.write_bytes(payload)
                        print(f"Wrote telemetry payload: {output}")
                        dump_telemetry_memory()
            result = x1  # Android Intent builder methods return this
        else:
            print(f"UNMODELED CallObjectMethod method={method_info}")
            result = 0
        uc.reg_write(UC_ARM64_REG_X0, result)
    elif index in (61, 62, 63):  # CallVoidMethod[VA]
        method_info = java_method_info.get(x2)
        print(f"JNI CallVoidMethod {method_info[1].decode(errors='replace') if method_info else '?'}")
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif index in (37, 38, 39):  # CallBooleanMethod[VA]
        method_info = java_method_info.get(x2)
        instance = java_objects.get(x1, {})
        arguments = instance.get("args", [])
        if method_info and method_info[1] == b"isNativeMethod":
            result = int(bool(instance.get("native", False)))
        elif method_info and method_info[1] == b"booleanValue" and arguments:
            result = int(bool(arguments[0]))
        else:
            result = 0
        uc.reg_write(UC_ARM64_REG_X0, result)
    elif index in (49, 50, 51):  # CallIntMethod[VA]
        method_info = java_method_info.get(x2)
        instance = java_objects.get(x1, {})
        arguments = instance.get("args", [])
        if method_info and method_info[1] == b"lastIndexOf" and x1 in java_strings:
            character = read_instance_call_args(index, x3, 1)[0] & 0xFF
            result = java_strings[x1].rfind(bytes([character]))
        elif method_info and method_info[1] == b"getLineNumber":
            result = int(instance.get("line", 0))
        elif method_info and method_info[1] in (b"intValue", b"shortValue", b"byteValue", b"charValue") and arguments:
            result = arguments[0]
        else:
            result = 0
        uc.reg_write(UC_ARM64_REG_X0, result & 0xFFFFFFFF)
    elif index in (52, 53, 54):  # CallLongMethod[VA]
        method_info = java_method_info.get(x2)
        result = 0
        instance = java_objects.get(x1, {})
        arguments = instance.get("args", [])
        if method_info and method_info[1] == b"length":
            if arguments and arguments[0] in java_strings:
                path = java_strings[arguments[0]].decode(errors="replace")
                # java.io.File.length() comes from stat.st_size. Procfs files
                # report zero even though read() returns generated contents.
                result = 0 if path.startswith("/proc/") else len(virtual_file_contents(path))
                print(f"JNI File.length path={path!r} -> {result}")
        elif method_info and method_info[1] == b"longValue" and arguments:
            result = arguments[0]
            print(f"JNI CallLongValue object={x1:#x} args={[hex(value) for value in arguments]} -> {result:#x}")
        else:
            print(f"UNMODELED CallLongMethod method={method_info}")
        uc.reg_write(UC_ARM64_REG_X0, result)
    elif index in (114, 115, 116):  # CallStaticObjectMethod[VA]
        method_info = java_method_info.get(x2)
        print(f"JNI CallStaticObjectMethod index={index} method={method_info}")
        if method_info and method_info[1] == b"invoke":
            if index == 115:
                values = read_va_list_args(x3, 2)
            elif index == 116:
                values = [struct.unpack("<Q", bytes(uc.mem_read(x3 + offset * 8, 8)))[0]
                          for offset in range(2)]
            else:
                values = [x3, uc.reg_read(UC_ARM64_REG_X4)]
            # VMRunner.invoke decrypts (a no-op for this build) and calls the
            # registered native executeVM. Tail-enter it with the same jobject[]
            # that ExecuteProgram supplied through the variadic JNI call.
            uc.reg_write(UC_ARM64_REG_X0, ENV)
            uc.reg_write(UC_ARM64_REG_X1, 0)
            uc.reg_write(UC_ARM64_REG_X2, BYTE_ARRAY)
            uc.reg_write(UC_ARM64_REG_X3, values[1])
            uc.reg_write(UC_ARM64_REG_PC, 0x6A61C)
            return
        if method_info and method_info[1] == b"getContext":
            if not java_context:
                java_context = new_java_handle()
                java_objects[java_context] = {
                    "class": java_classes.get(b"android/content/Context", 0),
                    "constructor": b"<existing>", "args": [],
                }
            uc.reg_write(UC_ARM64_REG_X0, java_context)
        else:
            uc.reg_write(UC_ARM64_REG_X0, 0)
    elif index in (117, 118, 119):  # CallStaticBooleanMethod[VA]
        method_info = java_method_info.get(x2)
        print(f"JNI CallStaticBooleanMethod {method_info[1].decode(errors='replace') if method_info else '?'} -> False")
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif index in (33, 113):  # GetMethodID, GetStaticMethodID
        name, signature = cstring(x2), cstring(x3)
        key = (x1, name, signature)
        if key not in java_methods:
            method = new_java_handle()
            java_methods[key] = method
            java_method_info[method] = key
        print(f"JNI {'GetStaticMethodID' if index == 113 else 'GetMethodID'} "
              f"{name.decode(errors='replace')!r} {signature.decode(errors='replace')!r}")
        uc.reg_write(UC_ARM64_REG_X0, java_methods[key])
    elif index == 144:  # GetStaticFieldID
        name, signature = cstring(x2), cstring(x3)
        field = new_java_handle()
        java_field_info[field] = (x1, name, signature)
        print(f"JNI GetStaticFieldID {name.decode(errors='replace')!r} "
              f"{signature.decode(errors='replace')!r}")
        uc.reg_write(UC_ARM64_REG_X0, field)
    elif index in (145, 146, 147, 148, 149, 150, 151):  # GetStatic*Field
        field_info = java_field_info.get(x2)
        name = field_info[1] if field_info else b""
        values = {
            b"SDK_INT": 35,
            b"FLAG_ACTIVITY_NEW_TASK": 0x10000000,
            b"FLAG_ACTIVITY_CLEAR_TASK": 0x00008000,
            b"FLAG_ACTIVITY_CLEAR_TOP": 0x04000000,
            b"FLAG_ACTIVITY_SINGLE_TOP": 0x20000000,
            b"FLAG_GRANT_READ_URI_PERMISSION": 1,
            b"FLAG_GRANT_WRITE_URI_PERMISSION": 2,
        }
        print(f"JNI GetStaticField {field_info}")
        uc.reg_write(UC_ARM64_REG_X0, values.get(name, 0))
    elif index == 167:  # NewStringUTF
        value = cstring(x1)
        handle = new_java_handle()
        java_strings[handle] = value
        print(f"JNI NewStringUTF {value.decode(errors='replace')!r}")
        uc.reg_write(UC_ARM64_REG_X0, handle)
    elif index == 168:  # GetStringUTFLength
        uc.reg_write(UC_ARM64_REG_X0, len(java_strings.get(x1, b"")))
    elif index == 169:  # GetStringUTFChars
        value = java_strings.get(x1, b"")
        print(f"JNI GetStringUTFChars {value!r}")
        address = alloc(len(value) + 1)
        uc.mem_write(address, value + b"\0")
        if x2:
            uc.mem_write(x2, b"\x01")
        uc.reg_write(UC_ARM64_REG_X0, address)
    elif index == 170:  # ReleaseStringUTFChars
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif index == 171:  # GetArrayLength
        if x1 == BYTE_ARRAY:
            result = len(asset)
        elif x1 == OBJECT_ARRAY:
            result = 1
        elif x1 in java_byte_arrays:
            result = java_byte_arrays[x1][1]
        else:
            result = len(java_arrays.get(x1, ()))
        print(f"JNI GetArrayLength array={x1:#x} -> {result}")
        uc.reg_write(UC_ARM64_REG_X0, result)
    elif index == 172:  # NewObjectArray
        length = x1 & 0xFFFFFFFF
        handle = new_java_handle()
        java_arrays[handle] = [x3] * length
        print(f"JNI NewObjectArray handle={handle:#x} length={length} initial={x3:#x}")
        uc.reg_write(UC_ARM64_REG_X0, handle)
    elif index == 173:  # GetObjectArrayElement
        if x1 == OBJECT_ARRAY:
            result = 0  # sole DT_INIT argument is null
        else:
            values = java_arrays.get(x1, ())
            result = values[x2] if x2 < len(values) else 0
        print(f"JNI GetObjectArrayElement array={x1:#x} index={x2} -> {result:#x} "
              f"instance={java_objects.get(result)}")
        uc.reg_write(UC_ARM64_REG_X0, result)
    elif index == 174:  # SetObjectArrayElement
        values = java_arrays.get(x1)
        if values is not None and x2 < len(values):
            values[x2] = x3
        print(f"JNI SetObjectArrayElement array={x1:#x} index={x2} value={x3:#x} "
              f"instance={java_objects.get(x3)}")
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif index == 176:  # NewByteArray
        length = x1 & 0xFFFFFFFF
        data = alloc(length)
        uc.mem_write(data, bytes(length))
        handle = new_java_handle()
        java_byte_arrays[handle] = (data, length)
        uc.reg_write(UC_ARM64_REG_X0, handle)
    elif index == 184:  # GetByteArrayElements
        uc.reg_write(UC_ARM64_REG_X0, java_byte_arrays.get(x1, (0, 0))[0])
    elif index == 192:  # ReleaseByteArrayElements
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif index == 200:  # GetByteArrayRegion
        start = x2 & 0xFFFFFFFF
        length = x3 & 0xFFFFFFFF
        destination = uc.reg_read(UC_ARM64_REG_X4)
        if x1 == BYTE_ARRAY:
            contents = asset[start:start + length]
        else:
            data, capacity = java_byte_arrays.get(x1, (0, 0))
            contents = bytes(uc.mem_read(data + start, min(length, max(0, capacity - start)))) if data else b""
        uc.mem_write(destination, contents)
    elif index == 208:  # SetByteArrayRegion
        data, capacity = java_byte_arrays.get(x1, (0, 0))
        start = x2 & 0xFFFFFFFF
        length = min(x3 & 0xFFFFFFFF, max(0, capacity - start))
        source = uc.reg_read(UC_ARM64_REG_X4)
        if data and length:
            uc.mem_write(data + start, bytes(uc.mem_read(source, length)))
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif index == 215:  # RegisterNatives
        print(f"JNI RegisterNatives count={x3}")
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif index in (21, 25):  # NewGlobalRef, NewLocalRef
        uc.reg_write(UC_ARM64_REG_X0, x1)
    elif index == 27:  # AllocObject
        uc.reg_write(UC_ARM64_REG_X0, new_java_handle())
    elif index in (15, 17, 22, 23, 26, 228):  # exception/reference/capacity helpers
        uc.reg_write(UC_ARM64_REG_X0, 0)
    else:
        print(f"UNHANDLED JNI index={index} pc={uc.reg_read(UC_ARM64_REG_PC):#x} "
              f"x1={x1:#x}")
        uc.reg_write(UC_ARM64_REG_X0, 0)
    return_to_lr()

def invoke_next_dl_module() -> bool:
    global dl_module_index
    if dl_module_index >= len(dl_modules):
        return False
    name = dl_modules[dl_module_index]
    dl_module_index += 1
    if name in ("libc.so", "libm.so", "libdl.so"):
        path = f"/apex/com.android.runtime/lib64/bionic/{name}"
        base = 0
    elif name == "liblog.so":
        path = f"/system/lib64/{name}"
        base = 0
    else:
        path = f"{app_dir}/lib/arm64/{name}"
        base = (args.target_base if name == "libil2cpp.so" and args.target_library else
                native_view_base if name == "libpairipcore.so" else 0)
    name_address = alloc(len(path) + 1)
    uc.mem_write(name_address, path.encode() + b"\0")
    info = alloc(32)
    phdr = base + 0x40 if name in ("libpairipcore.so", "libil2cpp.so") else 0
    phnum = 0
    if phdr:
        phnum = struct.unpack("<H", bytes(uc.mem_read(base + 0x38, 2)))[0]
    uc.mem_write(info, struct.pack("<QQQH6x", base, name_address, phdr, phnum))
    print(f"DL_MODULE index={dl_module_index - 1} name={name} path={path} "
          f"base={base:#x} phdr={phdr:#x} phnum={phnum}")
    uc.reg_write(UC_ARM64_REG_X0, info)
    uc.reg_write(UC_ARM64_REG_X1, 32)
    uc.reg_write(UC_ARM64_REG_X2, dl_callback_data)
    uc.reg_write(UC_ARM64_REG_X30, DL_CALLBACK_SENTINEL)
    uc.reg_write(UC_ARM64_REG_PC, dl_callback)
    return True


def invoke_next_property() -> bool:
    global property_index
    if property_index >= len(property_infos):
        return False
    info = property_infos[property_index]
    property_index += 1
    name, value = property_values[info]
    print(f"PROPERTY_CALLBACK index={property_index - 1} name={name.decode(errors='replace')!r} "
          f"value={value.decode(errors='replace')!r}")
    uc.reg_write(UC_ARM64_REG_X0, info)
    uc.reg_write(UC_ARM64_REG_X1, property_callback_data)
    uc.reg_write(UC_ARM64_REG_X30, PROPERTY_CALLBACK_SENTINEL)
    uc.reg_write(UC_ARM64_REG_PC, property_callback)
    return True


def handle_plt(address: int, name: str) -> None:
    global current_thread, main_context, worker_context, thread_switches
    global dl_callback, dl_callback_data, dl_return_pc, dl_module_index, dl_modules
    global property_callback, property_callback_data, property_return_pc
    global property_index, property_infos, property_values
    global main_resume_pc, worker_resume_pc, errno_address
    global next_fake_child_pid, dumpable_state
    global next_pthread_key, pthread_once_return_pc
    x0 = uc.reg_read(UC_ARM64_REG_X0)
    x1 = uc.reg_read(UC_ARM64_REG_X1)
    x2 = uc.reg_read(UC_ARM64_REG_X2)
    if name == "malloc":
        uc.reg_write(UC_ARM64_REG_X0, alloc(x0))
    elif name == "calloc":
        result = alloc(x0 * x1)
        uc.mem_write(result, bytes(x0 * x1))
        uc.reg_write(UC_ARM64_REG_X0, result)
    elif name == "realloc":
        result = alloc(x1)
        old_size = allocations.get(x0, 0)
        if x0 and old_size:
            uc.mem_write(result, bytes(uc.mem_read(x0, min(old_size, x1))))
        uc.reg_write(UC_ARM64_REG_X0, result)
    elif name == "free":
        pass
    elif name == "memset":
        uc.mem_write(x0, bytes([x1 & 0xFF]) * x2)
    elif name in ("memcpy", "memmove"):
        uc.mem_write(x0, bytes(uc.mem_read(x1, x2)))
    elif name == "strlen":
        uc.reg_write(UC_ARM64_REG_X0, len(cstring(x0)))
    elif name in ("strcmp", "strncmp", "memcmp"):
        if name == "strcmp":
            left, right = cstring(x0), cstring(x1)
        elif name == "strncmp":
            left, right = cstring(x0)[:x2], cstring(x1)[:x2]
        else:
            left, right = bytes(uc.mem_read(x0, x2)), bytes(uc.mem_read(x1, x2))
        result = 0 if left == right else (-1 if left < right else 1)
        if name != "memcmp" or any(token in left + right for token in (b"pairip", b"VMRunner", b"Startup", b"SafeDK")):
            print(f"{name} left={left[:160]!r} right={right[:160]!r} -> {result}")
        uc.reg_write(UC_ARM64_REG_X0, result & 0xFFFFFFFFFFFFFFFF)
    elif name == "memchr":
        data = bytes(uc.mem_read(x0, x2))
        index = data.find(bytes([x1 & 0xFF]))
        uc.reg_write(UC_ARM64_REG_X0, 0 if index < 0 else x0 + index)
    elif name == "strtoull":
        start = x0
        while uc.mem_read(start, 1)[0] in b" \t\r\n\v\f":
            start += 1
        cursor = start
        base = x2 & 0xFFFFFFFF
        digits = b"0123456789abcdefghijklmnopqrstuvwxyz"
        if base == 0:
            base = 16 if bytes(uc.mem_read(cursor, 2)).lower().startswith(b"0x") else 10
        if base == 16 and bytes(uc.mem_read(cursor, 2)).lower().startswith(b"0x"):
            cursor += 2
        value = 0
        consumed = 0
        while True:
            byte = uc.mem_read(cursor, 1)[0]
            digit = digits.find(bytes([byte]).lower())
            if digit < 0 or digit >= base:
                break
            value = value * base + digit
            cursor += 1
            consumed += 1
        if x1:
            uc.mem_write(x1, struct.pack("<Q", cursor if consumed else x0))
        uc.reg_write(UC_ARM64_REG_X0, value & 0xFFFFFFFFFFFFFFFF)
    elif name == "dlopen":
        print(f"DLOPEN {cstring(x0).decode(errors='replace') if x0 else '<self>'}")
        uc.reg_write(UC_ARM64_REG_X0, 1)
    elif name == "dlsym":
        symbol = cstring(x1)
        address = fake_symbols.setdefault(symbol, FAKE_SYMBOL + len(fake_symbols) * 0x100)
        if symbol == b"environ" and struct.unpack("<Q", bytes(uc.mem_read(address, 8)))[0] == 0:
            environment_array = alloc(8)
            uc.mem_write(environment_array, struct.pack("<Q", 0))
            uc.mem_write(address, struct.pack("<Q", environment_array))
        print(f"DLSYM {symbol.decode(errors='replace')} -> {address:#x}")
        uc.reg_write(UC_ARM64_REG_X0, address)
    elif name == "dl_iterate_phdr":
        print(f"DL_ITERATE_PHDR callback={x0:#x} data={x1:#x}")
        dl_callback = x0
        dl_callback_data = x1
        dl_return_pc = uc.reg_read(UC_ARM64_REG_X30)
        # SafeDKApplication's static initializer loads pairipcore before Unity.
        # Device logcat confirms that libmain/libunity/libil2cpp are absent
        # throughout ERz; expose them only for the later IL2CPP DT_INIT phase.
        dl_modules = []
        if target_runtime_visible:
            dl_modules += ["libmain.so", "libunity.so"]
            if args.target_library:
                dl_modules.append("libil2cpp.so")
        dl_modules += ["libpairipcore.so", "liblog.so", "libm.so", "libdl.so", "libc.so"]
        dl_module_index = 0
        invoke_next_dl_module()
        return
    elif name == "dlclose":
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif name == "dlerror":
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif name == "fmod":
        left = struct.unpack("<d", struct.pack("<Q", uc.reg_read(UC_ARM64_REG_D0)))[0]
        right = struct.unpack("<d", struct.pack("<Q", uc.reg_read(UC_ARM64_REG_D1)))[0]
        result = math.fmod(left, right) if right else math.nan
        uc.reg_write(UC_ARM64_REG_D0, struct.unpack("<Q", struct.pack("<d", result))[0])
    elif name == "fmodf":
        left = struct.unpack("<f", struct.pack("<I", uc.reg_read(UC_ARM64_REG_S0)))[0]
        right = struct.unpack("<f", struct.pack("<I", uc.reg_read(UC_ARM64_REG_S1)))[0]
        result = math.fmod(left, right) if right else math.nan
        uc.reg_write(UC_ARM64_REG_S0, struct.unpack("<I", struct.pack("<f", result))[0])
    elif name == "pthread_create":
        # Run the worker cooperatively until its condition-variable wait, then
        # resume the main thread. A synchronous call without this switch would
        # deadlock in the worker's empty-queue loop.
        argument = uc.reg_read(UC_ARM64_REG_X3)
        print(f"PTHREAD_CREATE start={x2:#x} arg={argument:#x}")
        uc.mem_write(x0, struct.pack("<Q", 1))
        uc.reg_write(UC_ARM64_REG_X0, 0)
        return_to_lr()
        main_resume_pc = uc.reg_read(UC_ARM64_REG_PC)
        main_context = uc.context_save()
        current_thread = "worker"
        thread_switches += 1
        uc.reg_write(UC_ARM64_REG_SP, STACK + 0x100000)
        uc.reg_write(UC_ARM64_REG_X0, argument)
        uc.reg_write(UC_ARM64_REG_X30, WORKER_SENTINEL)
        uc.reg_write(UC_ARM64_REG_PC, x2)
        return
    elif name == "pthread_cond_wait" and current_thread == "worker" and main_context is not None:
        # The worker is now blocked. Save the state in which its wait will
        # eventually return and resume the main thread after pthread_create or
        # pthread_cond_signal.
        uc.reg_write(UC_ARM64_REG_X0, 0)
        return_to_lr()
        worker_resume_pc = uc.reg_read(UC_ARM64_REG_PC)
        worker_context = uc.context_save()
        context = main_context
        resume_pc = main_resume_pc
        main_context = None
        current_thread = "main"
        thread_switches += 1
        uc.context_restore(context)
        uc.reg_write(UC_ARM64_REG_PC, resume_pc)
        return
    elif name in ("pthread_cond_signal", "pthread_cond_broadcast") and current_thread == "main" and worker_context is not None:
        # A queued work item wakes the blocked worker. Return from signal in the
        # saved main context later, when the worker waits again.
        uc.reg_write(UC_ARM64_REG_X0, 0)
        return_to_lr()
        main_resume_pc = uc.reg_read(UC_ARM64_REG_PC)
        main_context = uc.context_save()
        context = worker_context
        resume_pc = worker_resume_pc
        worker_context = None
        current_thread = "worker"
        thread_switches += 1
        uc.context_restore(context)
        uc.reg_write(UC_ARM64_REG_PC, resume_pc)
        return
    elif name == "pthread_once":
        once_value = struct.unpack("<I", bytes(uc.mem_read(x0, 4)))[0]
        rare_call_log(name, f"control={x0:#x} routine={x1:#x} value={once_value:#x}")
        if once_value == 0:
            uc.mem_write(x0, struct.pack("<I", 1))
            pthread_once_return_pc = uc.reg_read(UC_ARM64_REG_X30)
            uc.reg_write(UC_ARM64_REG_X30, PTHREAD_ONCE_SENTINEL)
            uc.reg_write(UC_ARM64_REG_PC, x1)
            return
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif name == "pthread_key_create":
        key = next_pthread_key
        next_pthread_key += 1
        pthread_key_destructors[key] = x1
        uc.mem_write(x0, struct.pack("<I", key))
        rare_call_log(name, f"key={key} destructor={x1:#x}")
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif name == "pthread_setspecific":
        pthread_key_values[(current_thread, x0)] = x1
        rare_call_log(name, f"thread={current_thread} key={x0} value={x1:#x}")
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif name == "pthread_getspecific":
        value = pthread_key_values.get((current_thread, x0), 0)
        rare_call_log(name, f"thread={current_thread} key={x0} -> {value:#x}")
        uc.reg_write(UC_ARM64_REG_X0, value)
    elif name == "pthread_key_delete":
        pthread_key_destructors.pop(x0, None)
        for key in [key for key in pthread_key_values if key[1] == x0]:
            del pthread_key_values[key]
        rare_call_log(name, f"key={x0}")
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif name in (
        "pthread_mutex_lock", "pthread_mutex_unlock", "pthread_cond_signal",
        "pthread_cond_broadcast", "pthread_cond_wait", "pthread_join", "pthread_detach",
    ):
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif name == "posix_memalign":
        uc.mem_write(x0, struct.pack("<Q", alloc(x2, x1)))
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif name == "getpid":
        uc.reg_write(UC_ARM64_REG_X0, emulated_pid)
    elif name == "getpagesize":
        uc.reg_write(UC_ARM64_REG_X0, PAGE)
    elif name == "getauxval":
        rare_call_log(name, f"type={x0:#x} -> 0")
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif name == "system_property_foreach":
        rare_call_log(name, f"callback={x0:#x} data={x1:#x} properties={len(system_properties)}")
        property_callback = x0
        property_callback_data = x1
        property_return_pc = uc.reg_read(UC_ARM64_REG_X30)
        property_index = 0
        property_infos = []
        property_values = {}
        for property_name, property_value in system_properties.items():
            info = alloc(4)
            property_infos.append(info)
            property_values[info] = (property_name.encode(), property_value.encode())
        if invoke_next_property():
            return
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif name == "system_property_read":
        property_name, property_value = property_values.get(x0, (b"", b""))
        if x1:
            uc.mem_write(x1, property_name[:31] + b"\0")
        if x2:
            uc.mem_write(x2, property_value[:91] + b"\0")
        print(f"PROPERTY_READ info={x0:#x} name={property_name!r} value={property_value!r}")
        uc.reg_write(UC_ARM64_REG_X0, len(property_value))
    elif name == "errno_location":
        if not errno_address:
            errno_address = alloc(4)
            uc.mem_write(errno_address, bytes(4))
        uc.reg_write(UC_ARM64_REG_X0, errno_address)
    elif name == "syscall":
        # Model the no-debugger result of PairIP's prctl/clone/wait4 self-test.
        # The child path performs ptrace operations and exits zero; the parent
        # only needs a successful clone and a zero exit status to observe that.
        result = -1
        detail = "unsupported"
        if x0 == 0xA7:  # prctl
            option = x1 & 0xFFFFFFFF
            if option == 3:  # PR_GET_DUMPABLE
                result = dumpable_state
            elif option == 4:  # PR_SET_DUMPABLE
                dumpable_state = x2 & 0xFFFFFFFF
                result = 0
            elif option == 0x59616D61:  # PR_SET_PTRACER
                result = 0
            detail = f"prctl option={option:#x} arg={x2:#x}"
        elif x0 == 0xDC and x1 == 0:  # clone(0), fork-like self-test child
            result = next_fake_child_pid
            next_fake_child_pid += 1
            fake_child_pids.add(result)
            detail = f"clone parent child={result}"
        elif x0 == 0x104 and x1 in fake_child_pids:  # wait4
            if x2:
                uc.mem_write(x2, bytes(4))  # WIFEXITED, WEXITSTATUS(0)
            result = x1
            fake_child_pids.remove(x1)
            detail = f"wait4 child={x1} exit_status=0"
        elif x0 == 0x81 and x1 in fake_child_pids:  # kill cleanup
            fake_child_pids.remove(x1)
            result = 0
            detail = f"kill child={x1}"
        elif x0 == 0xB2:  # gettid
            result = emulated_pid if current_thread == "main" else emulated_pid + 1000
            detail = f"gettid thread={current_thread}"
        rare_call_log(name, f"number={x0:#x} {detail} -> {result}")
        uc.reg_write(UC_ARM64_REG_X0, result & 0xFFFFFFFFFFFFFFFF)
    elif name in ("fprintf", "snprintf"):
        if name == "snprintf":
            try:
                format_string = cstring(x2)[:160]
            except (UcError, RuntimeError):
                format_string = b"<invalid>"
            rare_call_log(name, f"buffer={x0:#x} size={x1:#x} format={format_string!r} -> empty")
        if name == "snprintf" and x0 and x1:
            uc.mem_write(x0, b"\0")
        uc.reg_write(UC_ARM64_REG_X0, 0)
    elif name in ("abort", "stack_chk_fail"):
        raise RuntimeError(f"PairIP called {name} at LR={uc.reg_read(UC_ARM64_REG_X30):#x}")
    else:
        raise RuntimeError(f"unimplemented PLT stub {name} at {address:#x}")
    return_to_lr()


def emulate_original_tls(descriptor: int) -> None:
    """Reference implementation of the unpatched per-thread TLS resolver."""
    key = (current_thread, descriptor)
    pointer = original_tls_slots.get(key, 0)
    if pointer == 0:
        size = struct.unpack("<Q", uc.mem_read(descriptor, 8))[0]
        alignment = max(struct.unpack("<Q", uc.mem_read(descriptor + 8, 8))[0], 8)
        if alignment & (alignment - 1):
            raise RuntimeError(f"invalid TLS alignment {alignment:#x} at {descriptor:#x}")
        initializer = struct.unpack("<Q", uc.mem_read(descriptor + 24, 8))[0]
        raw = alloc(size + alignment + 7, alignment=16)
        pointer = (raw + alignment + 7) & -alignment
        uc.mem_write(pointer - 8, struct.pack("<Q", raw))
        if initializer:
            uc.mem_write(pointer, bytes(uc.mem_read(initializer, size)))
        else:
            uc.mem_write(pointer, bytes(size))
        original_tls_slots[key] = pointer
        print(f"TLS_ORIGINAL thread={current_thread} descriptor={descriptor:#x} "
              f"size={size:#x} pointer={pointer:#x}", flush=True)
    uc.reg_write(UC_ARM64_REG_X0, pointer)
    return_to_lr()


def code_hook(_uc, address, size, _user):
    global insn_count, vm_steps, vm_base, vm_length, last_vm_dispatch_insn
    global current_vm_pc, current_opcode, current_thread, main_context, worker_context, thread_switches
    global main_resume_pc, worker_resume_pc, property_read_return_pc
    global active_opcode_trace, active_opcode_name
    if args.emulate_original_tls and address == 0x29dac:
        emulate_original_tls(uc.reg_read(UC_ARM64_REG_X0))
        return
    if active_opcode_trace is not None:
        if address in (0x30A74, 0x3DB64, 0x6E914):
            output = Path(f"reverse/build/v18/{active_opcode_name}.trace")
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_text("\n".join(f"{item:#x}" for item in active_opcode_trace) + "\n")
            print(f"Wrote {len(active_opcode_trace)}-instruction opcode trace: {output}")
            active_opcode_trace = None
        else:
            active_opcode_trace.append(address)
    insn_count += 1
    trace.append(address)
    if vm_steps and insn_count - last_vm_dispatch_insn > 10_000_000:
        raise RuntimeError(
            f"no VM dispatch for 10M instructions at {address:#x}; "
            f"trace={' '.join(hex(item) for item in trace)}"
        )
    if address == PTHREAD_ONCE_SENTINEL:
        uc.reg_write(UC_ARM64_REG_X0, 0)
        uc.reg_write(UC_ARM64_REG_X30, pthread_once_return_pc)
        uc.reg_write(UC_ARM64_REG_PC, pthread_once_return_pc)
        return
    if address == PROPERTY_READ_CALLBACK_SENTINEL:
        uc.reg_write(UC_ARM64_REG_X0, 0)
        uc.reg_write(UC_ARM64_REG_X30, property_read_return_pc)
        uc.reg_write(UC_ARM64_REG_PC, property_read_return_pc)
        return
    if address == PROPERTY_CALLBACK_SENTINEL:
        if not invoke_next_property():
            uc.reg_write(UC_ARM64_REG_X0, 0)
            uc.reg_write(UC_ARM64_REG_X30, property_return_pc)
            uc.reg_write(UC_ARM64_REG_PC, property_return_pc)
        return
    if address == DL_CALLBACK_SENTINEL:
        result = uc.reg_read(UC_ARM64_REG_X0)
        print(f"DL_CALLBACK_RESULT index={dl_module_index - 1} result={result:#x}")
        if result != 0 or not invoke_next_dl_module():
            uc.reg_write(UC_ARM64_REG_X0, result)
            uc.reg_write(UC_ARM64_REG_X30, dl_return_pc)
            uc.reg_write(UC_ARM64_REG_PC, dl_return_pc)
        return
    if address == WORKER_SENTINEL:
        print("PAIRIP worker returned")
        if main_context is not None:
            context = main_context
            resume_pc = main_resume_pc
            main_context = None
            worker_context = None
            current_thread = "main"
            thread_switches += 1
            uc.context_restore(context)
            uc.reg_write(UC_ARM64_REG_PC, resume_pc)
        else:
            uc.emu_stop()
        return
    if FAKE_FN <= address < FAKE_FN + 0x10000:
        handle_jni((address - FAKE_FN) // 0x100)
        return
    if FAKE_SYMBOL <= address < FAKE_SYMBOL + 0x10000:
        symbol_index = (address - FAKE_SYMBOL) // 0x100
        symbol_name = next((name for name, value in fake_symbols.items()
                            if value == FAKE_SYMBOL + symbol_index * 0x100), b"?")
        print(f"CALL {symbol_name.decode(errors='replace')} at {address:#x}")
        if symbol_name == b"__system_property_read_callback":
            info = uc.reg_read(UC_ARM64_REG_X0)
            callback = uc.reg_read(UC_ARM64_REG_X1)
            cookie = uc.reg_read(UC_ARM64_REG_X2)
            property_name, property_value = property_values.get(info, (b"", b""))
            name_address = alloc(len(property_name) + 1)
            value_address = alloc(len(property_value) + 1)
            uc.mem_write(name_address, property_name + b"\0")
            uc.mem_write(value_address, property_value + b"\0")
            print(f"PROPERTY_READ_CALLBACK info={info:#x} callback={callback:#x} "
                  f"name={property_name!r} value={property_value!r}")
            property_read_return_pc = uc.reg_read(UC_ARM64_REG_X30)
            uc.reg_write(UC_ARM64_REG_X0, cookie)
            uc.reg_write(UC_ARM64_REG_X1, name_address)
            uc.reg_write(UC_ARM64_REG_X2, value_address)
            uc.reg_write(UC_ARM64_REG_X3, 0)
            uc.reg_write(UC_ARM64_REG_X30, PROPERTY_READ_CALLBACK_SENTINEL)
            uc.reg_write(UC_ARM64_REG_PC, callback)
            return
        uc.reg_write(UC_ARM64_REG_X0, 0)
        return_to_lr()
        return
    name = PLT.get(address)
    if name:
        handle_plt(address, name)
        return
    if address == 0x31304 and current_vm_pc == 0x1FFC1:
        sp = uc.reg_read(UC_ARM64_REG_SP)
        source_holder = struct.unpack('<Q', bytes(uc.mem_read(sp + 0x58, 8)))[0]
        source_base = struct.unpack('<Q', bytes(uc.mem_read(source_holder, 8)))[0]
        source_offset = struct.unpack('<I', bytes(uc.mem_read(sp + 0x60, 4)))[0]
        source = source_base + source_offset
        print(f"OP61_SOURCE source={source:#x} vm_offset={source - vm_base:#x} "
              f"value={uc.reg_read(UC_ARM64_REG_W8):#x} dest={uc.reg_read(UC_ARM64_REG_X10) + uc.reg_read(UC_ARM64_REG_W9):#x}")
    if address == 0x32EC8:
        base = uc.reg_read(UC_ARM64_REG_X0)
        decoded = uc.reg_read(UC_ARM64_REG_X1)
        fields = struct.unpack("<15I", bytes(uc.mem_read(decoded, 60)))
        expected1 = struct.unpack("<Q", bytes(uc.mem_read(decoded + 8, 8)))[0]
        expected2 = struct.unpack("<Q", bytes(uc.mem_read(decoded + 32, 8)))[0]
        mask = 0xFFFFFFFFFFFFFFFF

        def control_hash(offset, length):
            value = 0xCBF29CE484222325
            for byte in uc.mem_read(base + offset, length):
                value = (value * 0x100000001B3) & mask
                signed_byte = byte if byte < 0x80 else byte - 0x100
                value ^= signed_byte & mask
            xor32 = struct.unpack("<i", bytes(uc.mem_read(base + fields[0], 4)))[0]
            return (value ^ (xor32 & mask)) & mask

        value1 = control_hash(fields[4], fields[5] & 0xFFFF)
        value2 = control_hash(fields[10], fields[11] & 0xFFFF)
        initial = fields[14] & 0xFFFFFFFF
        if initial & 0x80000000:
            initial -= 0x100000000
        initial &= mask
        temporary = ((initial << 32) & initial) & mask
        selector = ((((initial << 32) & mask) ^ initial) + (~temporary & mask)
                    + temporary * 2 + 1) & mask
        comparison1 = ((selector + (~(value1 & selector) & mask))
                       - (selector | (value1 ^ mask))) & mask
        comparison2 = (selector ^ value2) & mask
        target = fields[6] if comparison1 == expected1 else (
            fields[12] if comparison2 == expected2 else fields[13])
        print("CONTROL_FIELDS " + " ".join(f"{index}:{value:#x}" for index, value in enumerate(fields)))
        print(f"CONTROL_HASH first={comparison1:#x}/{expected1:#x} "
              f"second={comparison2:#x}/{expected2:#x} target={target:#x}")
        def is_raw(offset, length):
            return (0 <= offset <= len(asset) - length and
                    bytes(uc.mem_read(base + offset, length)) == asset[offset:offset + length])
        print(f"CONTROL_CONTEXT vm_pc={current_vm_pc:#x} "
              f"raw_xor={is_raw(fields[0], 4)} "
              f"raw_first={is_raw(fields[4], fields[5] & 0xFFFF)} "
              f"raw_second={is_raw(fields[10], fields[11] & 0xFFFF)}")
    if current_opcode == 0x23 and address in (0x42B80, 0x42C18, 0x42C1C, 0x42C70, 0x42CA0, 0x56C6C):
        sp = uc.reg_read(UC_ARM64_REG_SP)
        if address == 0x42B80 and uc.reg_read(UC_ARM64_REG_X10) == 0:
            pointer = uc.reg_read(UC_ARM64_REG_X11)
            offset = pointer - vm_base
            length = uc.reg_read(UC_ARM64_REG_W21)
            raw = (0 <= offset <= len(asset) - length and
                   bytes(uc.mem_read(pointer, length)) == asset[offset:offset + length])
            print(f"OP23_HASH1 vm_pc={current_vm_pc:#x} input={pointer:#x} "
                  f"vm_offset={offset:#x} length={length:#x} raw={raw}")
        elif address == 0x42C18:
            print(f"OP23_TARGET1 vm_pc={current_vm_pc:#x} candidate={uc.reg_read(UC_ARM64_REG_W22):#x}")
        elif address == 0x42C1C:
            print(f"OP23_HASH1 vm_pc={current_vm_pc:#x} comparison={uc.reg_read(UC_ARM64_REG_X9):#x}/"
                  f"{uc.reg_read(UC_ARM64_REG_X10):#x}")
        elif address == 0x42C70 and uc.reg_read(UC_ARM64_REG_X9) == 0:
            pointer = uc.reg_read(UC_ARM64_REG_X8)
            offset = pointer - vm_base
            length = uc.reg_read(UC_ARM64_REG_W24)
            raw = (0 <= offset <= len(asset) - length and
                   bytes(uc.mem_read(pointer, length)) == asset[offset:offset + length])
            print(f"OP23_HASH2 vm_pc={current_vm_pc:#x} input={pointer:#x} "
                  f"vm_offset={offset:#x} length={length:#x} raw={raw}")
        elif address == 0x42CA0:
            alternate1 = struct.unpack('<I', bytes(uc.mem_read(sp + 0x450, 4)))[0]
            alternate2 = struct.unpack('<I', bytes(uc.mem_read(sp + 0x458, 4)))[0]
            print(f"OP23_HASH2 vm_pc={current_vm_pc:#x} comparison={uc.reg_read(UC_ARM64_REG_X8):#x}/"
                  f"{uc.reg_read(UC_ARM64_REG_X9):#x} targets={alternate1:#x}/{alternate2:#x}")
        elif address == 0x56C6C:
            print(f"OP23_TARGET vm_pc={current_vm_pc:#x} selected={uc.reg_read(UC_ARM64_REG_W22):#x}")
    if active_opcode_trace is not None and address == 0x6AA60:
        print(f"OP23_RESULT vm_pc={current_vm_pc:#x} w0={uc.reg_read(UC_ARM64_REG_W0):#x} "
              f"w19={uc.reg_read(UC_ARM64_REG_W19):#x} w20={uc.reg_read(UC_ARM64_REG_W20):#x} "
              f"w28={uc.reg_read(UC_ARM64_REG_W28):#x}")
    if active_opcode_trace is not None and address in (0x6A7C4, 0x6A8F4, 0x6A9F0, 0x6A9F4, 0x6A768):
        sp = uc.reg_read(UC_ARM64_REG_SP)
        print(f"OP23_NATIVE pc={address:#x} w1={uc.reg_read(UC_ARM64_REG_W1):#x} "
              f"w8={uc.reg_read(UC_ARM64_REG_W8):#x} w9={uc.reg_read(UC_ARM64_REG_W9):#x} "
              f"w10={uc.reg_read(UC_ARM64_REG_W10):#x} w11={uc.reg_read(UC_ARM64_REG_W11):#x} "
              f"w12={uc.reg_read(UC_ARM64_REG_W12):#x} x9={uc.reg_read(UC_ARM64_REG_X9):#x} "
              f"x11={uc.reg_read(UC_ARM64_REG_X11):#x} "
              f"sp30={struct.unpack('<I', bytes(uc.mem_read(sp + 0x30, 4)))[0]:#x} "
              f"sp34={struct.unpack('<I', bytes(uc.mem_read(sp + 0x34, 4)))[0]:#x} "
              f"sp40={struct.unpack('<I', bytes(uc.mem_read(sp + 0x40, 4)))[0]:#x}")
    if address == 0x45CA0:
        slot = uc.reg_read(UC_ARM64_REG_X8) + (uc.reg_read(UC_ARM64_REG_W9) & 0xFFFFFFFF)
        print(f"BUFFER_OBJECT vm_pc={current_vm_pc:#x} slot={slot:#x} "
              f"value={uc.reg_read(UC_ARM64_REG_X29):#x} base={uc.reg_read(UC_ARM64_REG_X8):#x} "
              f"index={uc.reg_read(UC_ARM64_REG_W9):#x}")
    if address == 0x46138:
        base = uc.reg_read(UC_ARM64_REG_X8)
        offset = uc.reg_read(UC_ARM64_REG_W14)
        operand = base + offset
        raw = struct.unpack("<H", bytes(uc.mem_read(operand, 2)))[0]
        signed = raw if raw < 0x8000 else raw - 0x10000
        print(f"OPENAT_LENGTH operand={operand:#x} vm_offset={operand - vm_base:#x} "
              f"raw={raw:#06x} signed={signed} w11={uc.reg_read(UC_ARM64_REG_W11):#x} "
              f"w14={offset:#x} w15={uc.reg_read(UC_ARM64_REG_W15):#x}")
    if address == 0x55B20:
        print(f"OPENAT_HASH length={uc.reg_read(UC_ARM64_REG_W27):#x} "
              f"expected={uc.reg_read(UC_ARM64_REG_X23):#x} "
              f"w24={uc.reg_read(UC_ARM64_REG_W24):#x} "
              f"w26={uc.reg_read(UC_ARM64_REG_W26):#x}")
    if (address == 0x55B3C and uc.reg_read(UC_ARM64_REG_W10) == 0
            and uc.reg_read(UC_ARM64_REG_W11) == 1):
        array = uc.reg_read(UC_ARM64_REG_X9)
        length = uc.reg_read(UC_ARM64_REG_W27)
        print(f"OPENAT_HASH_ARRAY address={array:#x} vm_offset={array - vm_base:#x} "
              f"length={length:#x}")
        if length > 0x100000:
            raise RuntimeError(f"unbounded openat hash length {length:#x}")
    if address == 0x46154:
        base = uc.reg_read(UC_ARM64_REG_X8)
        index = uc.reg_read(UC_ARM64_REG_W9)
        operand = base + index
        value = struct.unpack("<Q", bytes(uc.mem_read(operand, 8)))[0]
        print(f"OPENAT_OPERAND base={base:#x} index={index:#x} operand={operand:#x} "
              f"vm_offset={operand - vm_base:#x} value={value:#x} "
              f"w11={uc.reg_read(UC_ARM64_REG_W11):#x} "
              f"w19={uc.reg_read(UC_ARM64_REG_W19):#x} "
              f"w24={uc.reg_read(UC_ARM64_REG_W24):#x} "
              f"x23={uc.reg_read(UC_ARM64_REG_X23):#x}")
    if address in (0x30A74, 0x3DB64, 0x6E914):
        last_vm_dispatch_insn = insn_count
        vm_steps += 1
        wrapper = uc.reg_read(UC_ARM64_REG_X0)
        opcode = uc.reg_read(UC_ARM64_REG_X1) & 0xFFFF
        if address == 0x6E914:
            context = struct.unpack("<Q", bytes(uc.mem_read(wrapper + 0x88, 8)))[0]
        else:
            context = struct.unpack("<Q", bytes(uc.mem_read(wrapper + 8, 8)))[0]
        try:
            base, length, pc = struct.unpack("<QII", bytes(uc.mem_read(context, 16)))
            vm_base, vm_length = base, length
            current_vm_pc = pc
            current_opcode = opcode
            print(f"VM {vm_steps:5d} dispatch={address:#x} opcode={opcode:#04x} "
                  f"pc_after_opcode={pc:#x}")
            if address == 0x3DB64 and pc == 0x22CE6 and vm_length == len(asset):
                active_opcode_trace = []
                active_opcode_name = "ayum-post-telemetry-23"
            # Opcode-specific full traces are kept as saved diagnostic artifacts.
            # Do not continuously capture an open-ended native error path.
        except UcError:
            print(f"VM {vm_steps:5d} dispatch={address:#x} opcode={opcode:#04x} context={context:#x}")

def target_memory(_uc, access, address, size, value, _user):
    global target_reads, target_writes
    if access == 16:  # UC_MEM_READ
        target_reads += 1
        count = target_reads
        kind = "READ"
    else:
        target_writes += 1
        count = target_writes
        kind = "WRITE"
    if count <= 60:
        print(f"TARGET {kind} address={address:#x} size={size} value={value:#x} "
              f"pc={uc.reg_read(UC_ARM64_REG_PC):#x}")


def vm_variable_write(_uc, _access, address, size, value, _user):
    print(f"VM_VAR_WRITE address={address:#x} vm_offset={address - vm_base:#x} "
          f"size={size} value={value:#x} pc={uc.reg_read(UC_ARM64_REG_PC):#x} "
          f"lr={uc.reg_read(UC_ARM64_REG_X30):#x} vm_steps={vm_steps} "
          f"vm_pc={current_vm_pc:#x}")


def invalid_memory(_uc, access, address, size, value, _user):
    print(f"INVALID access={access} address={address:#x} size={size} "
          f"pc={uc.reg_read(UC_ARM64_REG_PC):#x} lr={uc.reg_read(UC_ARM64_REG_X30):#x}")
    print("registers:", " ".join(
        [f"x{index}={uc.reg_read(UC_ARM64_REG_X0 + index):#x}" for index in range(29)] +
        [f"x29={uc.reg_read(UC_ARM64_REG_X29):#x}",
         f"x30={uc.reg_read(UC_ARM64_REG_X30):#x}"]
    ))
    print("trace:", " ".join(f"{item:#x}" for item in trace))
    return False

def interrupt(_uc, intno, _user):
    pc = uc.reg_read(UC_ARM64_REG_PC)
    if pc == 0:
        raise RuntimeError(
            f"branched through an unresolved import: LR={uc.reg_read(UC_ARM64_REG_X30):#x} "
            f"x0={uc.reg_read(UC_ARM64_REG_X0):#x} x8={uc.reg_read(UC_ARM64_REG_X8):#x} "
            f"x9={uc.reg_read(UC_ARM64_REG_X9):#x}; trace={' '.join(hex(item) for item in trace)}"
        )
    number = uc.reg_read(UC_ARM64_REG_X8)
    arguments = [uc.reg_read(UC_ARM64_REG_X0 + index) for index in range(6)]
    detail = ""
    if number == 56:  # openat
        try:
            detail = f" path={cstring(arguments[1]).decode(errors='replace')!r}"
        except (UcError, RuntimeError):
            detail = " path=<invalid>"
    print(f"INTERRUPT {intno} pc={pc:#x} lr={uc.reg_read(UC_ARM64_REG_X30):#x} "
          f"syscall={number:#x} args={' '.join(f'{value:#x}' for value in arguments[:4])}{detail}")
    global next_virtual_fd, clock_ticks
    if number == 113:  # clock_gettime
        if args.clock_profile == "monotonic":
            clock_ticks += 1
            seconds = 1 + clock_ticks // 1000
            nanoseconds = (clock_ticks % 1000) * 1_000_000
        else:
            seconds, nanoseconds = 1, 0
        rare_call_log("clock_gettime", f"clock={arguments[0]:#x} value={seconds}.{nanoseconds:09d}")
        uc.mem_write(arguments[1], struct.pack("<QQ", seconds, nanoseconds))
        result = 0
    elif number == 56:  # openat
        try:
            path = cstring(arguments[1]).decode(errors="replace")
        except (UcError, RuntimeError):
            # Linux reports an invalid userspace pathname pointer to the caller;
            # it does not terminate the process or raise a host-side exception.
            result = -14  # EFAULT
        else:
            fd = next_virtual_fd
            next_virtual_fd += 1
            virtual_files[fd] = (path, virtual_file_contents(path), 0)
            if path.endswith("/"):
                virtual_directories[fd] = virtual_directory_entries(path)
                virtual_dir_offsets[fd] = 0
            result = fd
    elif number == 61:  # getdents64
        entries = virtual_directories.get(arguments[0])
        if entries is None:
            result = -20  # ENOTDIR
        else:
            offset = virtual_dir_offsets.get(arguments[0], 0)
            output = bytearray()
            while offset < len(entries):
                name, file_type = entries[offset]
                encoded = name.encode()
                record_length = (19 + len(encoded) + 1 + 7) & ~7
                if len(output) + record_length > arguments[2]:
                    break
                record = (struct.pack("<QQHB", offset + 1, offset + 1, record_length, file_type) +
                          encoded + b"\0")
                output.extend(record.ljust(record_length, b"\0"))
                offset += 1
            virtual_dir_offsets[arguments[0]] = offset
            uc.mem_write(arguments[1], bytes(output))
            result = len(output)
    elif number == 78:  # readlinkat
        name = cstring(arguments[1]).decode(errors="replace")
        range_name = name.rsplit("/", 1)[-1]
        target = virtual_map_link(range_name) if arguments[0] in virtual_directories or name.startswith("/proc/self/map_files/") else b""
        if target:
            result = min(len(target), arguments[3])
            uc.mem_write(arguments[2], target[:result])
        else:
            result = -2  # ENOENT
    elif number == 63:  # read
        entry = virtual_files.get(arguments[0])
        if entry is None:
            result = -9  # EBADF
        else:
            path, contents, offset = entry
            chunk = contents[offset:offset + arguments[2]]
            uc.mem_write(arguments[1], chunk)
            virtual_files[arguments[0]] = (path, contents, offset + len(chunk))
            result = len(chunk)
    elif number == 57:  # close
        virtual_directories.pop(arguments[0], None)
        virtual_dir_offsets.pop(arguments[0], None)
        result = 0 if virtual_files.pop(arguments[0], None) is not None else -9
    elif number == 172:  # getpid
        result = emulated_pid
    else:
        # Most remaining VM system calls are diagnostics/anti-tamper.
        result = -38  # ENOSYS
    print(f"SYSCALL result={result:#x}")
    uc.reg_write(UC_ARM64_REG_X0, result & 0xFFFFFFFFFFFFFFFF)

uc.hook_add(UC_HOOK_CODE, code_hook)
uc.hook_add(UC_HOOK_MEM_INVALID, invalid_memory)
uc.hook_add(UC_HOOK_INTR, interrupt)
if args.target_library:
    uc.hook_add(UC_HOOK_MEM_READ, target_memory,
                begin=args.target_base, end=args.target_base + target_end - 1)
    uc.hook_add(UC_HOOK_MEM_WRITE, target_memory,
                begin=args.target_base, end=args.target_base + target_end - 1)

if args.with_startup:
    for variable_offset in (0x161A0, 0x43855, 0x1BFD1):
        uc.hook_add(UC_HOOK_MEM_WRITE, vm_variable_write,
                    begin=0x300A0000 + variable_offset,
                    end=0x300A0000 + variable_offset + 7)
else:
    for variable_address, variable_size in ((0x300C1F5D, 8), (0x300B6CF7, 4)):
        uc.hook_add(UC_HOOK_MEM_WRITE, vm_variable_write,
                    begin=variable_address, end=variable_address + variable_size - 1)

if args.emulate_original_tls:
    # Seed the same JNI state as the patched run, but in independent storage
    # for the main thread and the cooperative worker thread.
    for thread in ("main", "worker"):
        attached = alloc(1)
        uc.mem_write(attached, b"\x01")
        env_slot = alloc(8)
        uc.mem_write(env_slot, struct.pack("<Q", ENV))
        original_tls_slots[(thread, 0x982e8)] = attached
        original_tls_slots[(thread, 0x98308)] = env_slot

try:
    if args.actual_entry:
        # Android loads pairipcore and calls JNI_OnLoad before libil2cpp's
        # DT_INIT stub invokes exported ExecuteProgram(assetName, args, 1, 0).
        java_vm = alloc(16)
        uc.mem_write(java_vm, bytes(16))
        uc.reg_write(UC_ARM64_REG_X0, java_vm)
        uc.reg_write(UC_ARM64_REG_X1, 0)
        uc.reg_write(UC_ARM64_REG_SP, STACK + 0x1F0000)
        uc.reg_write(UC_ARM64_REG_X30, SENTINEL)
        uc.emu_start(0x8A1FC, SENTINEL, count=args.max_insns)
        print(f"JNI_OnLoad returned {uc.reg_read(UC_ARM64_REG_X0):#x}")

        if args.with_startup:
            startup_path = Path("reverse/pairip-inputs/ERzS3xEHg1Vs5U4O")
            game_asset = asset
            asset = startup_path.read_bytes()
            print(f"Starting PairIP startup program {startup_path.name}")
            uc.reg_write(UC_ARM64_REG_X0, ENV)
            uc.reg_write(UC_ARM64_REG_X1, 0)
            uc.reg_write(UC_ARM64_REG_X2, BYTE_ARRAY)
            uc.reg_write(UC_ARM64_REG_X3, 0)
            uc.reg_write(UC_ARM64_REG_SP, STACK + 0x1F0000)
            uc.reg_write(UC_ARM64_REG_X30, SENTINEL)
            uc.emu_start(0x6A61C, SENTINEL, count=args.max_insns)
            print(f"Startup program returned {uc.reg_read(UC_ARM64_REG_X0):#x}")
            asset = game_asset
            target_runtime_visible = True

        asset_name = alloc(len(args.asset.name) + 1)
        uc.mem_write(asset_name, args.asset.name.encode() + b"\0")
        program_args = alloc(16)
        # Original DT_INIT executes ADRP x1, <ELF base>; STP x1, x30,
        # [sp,#-16]!; MOV x1,sp. Its sole argument is the target ELF load
        # base, NOT NULL. Preserve a zero override only as an explicit control.
        if args.dt_init_argument is None and not args.target_library:
            raise RuntimeError("Actual DT_INIT requires --target-library or an explicit --dt-init-argument control")
        init_argument = args.target_base if args.dt_init_argument is None else args.dt_init_argument
        uc.mem_write(program_args, struct.pack("<QQ", init_argument, 0))
        print(f"DT_INIT argument[0]={init_argument:#x}")
        uc.reg_write(UC_ARM64_REG_X0, asset_name)
        uc.reg_write(UC_ARM64_REG_X1, program_args)
        uc.reg_write(UC_ARM64_REG_X2, 1)
        uc.reg_write(UC_ARM64_REG_X3, 0)
        uc.reg_write(UC_ARM64_REG_SP, STACK + 0x1F0000)
        uc.reg_write(UC_ARM64_REG_X30, SENTINEL)
        uc.emu_start(0x69EB4, SENTINEL, count=args.max_insns)
    else:
        uc.reg_write(UC_ARM64_REG_X0, ENV)
        uc.reg_write(UC_ARM64_REG_X1, 0)
        uc.reg_write(UC_ARM64_REG_X2, BYTE_ARRAY)
        uc.reg_write(UC_ARM64_REG_X3, OBJECT_ARRAY)
        uc.reg_write(UC_ARM64_REG_SP, STACK + 0x1F0000)
        uc.reg_write(UC_ARM64_REG_X30, SENTINEL)
        # The JNI native entry's real prologue begins at 0x6a61c. The preceding
        # BL belongs to ExecuteProgram's impossible error branch.
        uc.emu_start(0x6A61C, SENTINEL, count=args.max_insns)
    print(f"completed pc={uc.reg_read(UC_ARM64_REG_PC):#x} insns={insn_count} vm_steps={vm_steps}")
except (UcError, RuntimeError, MemoryError) as error:
    print(f"stopped: {type(error).__name__}: {error}")
    print(f"pc={uc.reg_read(UC_ARM64_REG_PC):#x} lr={uc.reg_read(UC_ARM64_REG_X30):#x} "
          f"x0={uc.reg_read(UC_ARM64_REG_X0):#x} x1={uc.reg_read(UC_ARM64_REG_X1):#x} "
          f"insns={insn_count} vm_steps={vm_steps}")

if active_opcode_trace is not None:
    output = Path(f"reverse/build/v18/{active_opcode_name}.trace")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(f"{item:#x}" for item in active_opcode_trace) + "\n")
    print(f"Wrote partial {len(active_opcode_trace)}-instruction opcode trace: {output}")

print("RARE_CALL_COUNTS " + " ".join(f"{name}={count}" for name, count in sorted(rare_call_counts.items())))
print(f"target memory accesses: reads={target_reads} writes={target_writes}")
if vm_base and vm_length:
    output = Path("reverse/build/v18/emulated-vm-image.bin")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(bytes(uc.mem_read(vm_base, vm_length)))
    print(f"wrote mutable VM image: {output}")
