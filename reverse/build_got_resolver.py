#!/usr/bin/env python3
"""Reconstruct PairIP-removed IL2CPP imports with a compact DT_INIT resolver."""
from pathlib import Path
from elftools.elf.elffile import ELFFile
import json, re, subprocess

ROOT = Path(__file__).resolve().parent.parent
REV = ROOT / "reverse"
BUS = REV / "native/v8/lib/arm64-v8a/libil2cpp.so"
CLEAN = REV / "clean-reference/pocket-mortys-libil2cpp-2022.3.62f2.so"
SUMMARY = REV / "clean-call-matches-summary.txt"
OUT = REV / "build/v17"
GOT_SLOT_ZERO = 0x54662F0
SLOT_COUNT = 577
INIT_VA = 0x5A08000
INIT_FILE_OFFSET = 0x59F4000
INIT_PAGE_SIZE = 0x1000
DLSYM_PLT = 0x50BA2A0             # PLT stub for retained GOT slot 312
RELRO_WRITE_START = 0x5464000     # aligned for both 4 KiB and 16 KiB Android pages
RELRO_WRITE_SIZE = 0x4000

# These nine early slots have no unique clean-game call-context match. Their
# identities follow from exact wrapper semantics and contiguous libc import runs.
EARLY = {
    92: "getsockname", 93: "getpeername", 134: "fsync",
    222: "pthread_cond_init", 232: "setenv", 233: "unsetenv",
    266: "symlink", 275: "geteuid", 276: "getegid",
}
# For Bus slots 290..576, 207 retained anchors prove Bus slot = reference slot + 6.
TAIL = [387, 486, 488, 489, 525, 526, 527, 528, 529, 530, 531]

def relocations(path):
    with path.open("rb") as f:
        elf = ELFFile(f)
        sec = elf.get_section_by_name(".rela.plt")
        syms = elf.get_section(sec["sh_link"])
        return [(r["r_offset"], syms.get_symbol(r["r_info_sym"]).name)
                for r in sec.iter_relocations()]

def reconstruct():
    present = {(off - GOT_SLOT_ZERO) // 8 for off, _ in relocations(BUS)
               if off >= GOT_SLOT_ZERO and (off - GOT_SLOT_ZERO) % 8 == 0}
    missing = sorted(set(range(SLOT_COUNT)) - present)
    names = {}
    for line in SUMMARY.read_text().splitlines():
        m = re.match(r"\s*(\d+)\s+\S+\s+\S+\s+(\S+)", line)
        if m:
            names[int(m.group(1))] = m.group(2)
    clean_names = [name for _, name in relocations(CLEAN)]
    for slot in TAIL:
        names[slot] = clean_names[slot - 6]
    names.update(EARLY)
    assert len(missing) == 200, len(missing)
    assert set(names) == set(missing), (set(missing) - set(names), set(names) - set(missing))
    assert len(set(names.values())) == len(names), "unexpected duplicate names"
    return [(slot, names[slot]) for slot in missing]

def emit_assembly(entries):
    lines = [
        ".text", ".p2align 2", ".global pairip_replacement_init", ".type pairip_replacement_init, %function",
        ".extern dlsym_plt",
        f".equ got_slot_zero, 0x{GOT_SLOT_ZERO:x}",
        f".equ relro_write_start, 0x{RELRO_WRITE_START:x}",
        "pairip_replacement_init:",
        "  .inst 0xd503245f // BTI c",
        "  stp x29, x30, [sp, #-64]!", "  mov x29, sp",
        "  stp x19, x20, [sp, #16]", "  stp x21, x22, [sp, #32]", "  stp x23, x24, [sp, #48]",
        "  // PairIP's holes are in GNU RELRO. Temporarily make the full 16 KiB-aligned region writable.",
        "  adrp x0, relro_write_start", "  add x0, x0, :lo12:relro_write_start",
        f"  mov x1, #{RELRO_WRITE_SIZE}", "  mov x2, #3", "  mov x8, #226", "  svc #0", # arm64 mprotect
        "  adrp x19, resolver_table", "  add x19, x19, :lo12:resolver_table",
        "  adrp x23, resolver_names", "  add x23, x23, :lo12:resolver_names",
        "  adrp x21, got_slot_zero", "  add x21, x21, :lo12:got_slot_zero",
        f"  mov w20, #{len(entries)}", ".Lresolve_next:",
        "  ldrh w22, [x19], #2", "  ldrh w1, [x19], #2",
        "  add x1, x23, w1, uxtw", "  mov x0, xzr", "  bl dlsym_plt",
        "  str x0, [x21, x22, lsl #3]", "  subs w20, w20, #1", "  b.ne .Lresolve_next",
        "  // Restore GNU RELRO to read-only before ordinary IL2CPP constructors execute.",
        "  adrp x0, relro_write_start", "  add x0, x0, :lo12:relro_write_start",
        f"  mov x1, #{RELRO_WRITE_SIZE}", "  mov x2, #1", "  mov x8, #226", "  svc #0",
        "  ldp x23, x24, [sp, #48]", "  ldp x21, x22, [sp, #32]", "  ldp x19, x20, [sp, #16]",
        "  ldp x29, x30, [sp], #64", "  ret", ".size pairip_replacement_init, .-pairip_replacement_init",
        ".p2align 2", "resolver_names:",
    ]
    for slot, name in entries:
        lines += [f".Lname_{slot}:", f"  .asciz {json.dumps(name)}"]
    lines += [".p2align 1", "resolver_table:"]
    for slot, _ in entries:
        lines += [f"  .hword {slot}", f"  .hword .Lname_{slot} - resolver_names"]
    return "\n".join(lines) + "\n"

def run():
    OUT.mkdir(parents=True, exist_ok=True)
    entries = reconstruct()
    asm = OUT / "got-resolver.S"
    obj = OUT / "got-resolver.o"
    elf = OUT / "got-resolver.elf"
    raw = OUT / "got-resolver.bin"
    page = OUT / "got-resolver-page.bin"
    asm.write_text(emit_assembly(entries))
    subprocess.run(["aarch64-linux-gnu-as", "-o", obj, asm], check=True)
    subprocess.run(["aarch64-linux-gnu-ld", f"-Ttext=0x{INIT_VA:x}",
                    f"--defsym=dlsym_plt=0x{DLSYM_PLT:x}", "-o", elf, obj], check=True)
    subprocess.run(["aarch64-linux-gnu-objcopy", "-O", "binary", "--only-section=.text", elf, raw], check=True)
    data = raw.read_bytes()
    assert len(data) <= INIT_PAGE_SIZE, hex(len(data))
    page.write_bytes(data + bytes(INIT_PAGE_SIZE - len(data)))
    (OUT / "missing-import-map.txt").write_text("".join(f"{s:3} {n}\n" for s, n in entries))
    print(f"resolver bytes={len(data)} page={page} imports={len(entries)}")

if __name__ == "__main__":
    run()
