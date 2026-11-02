#!/usr/bin/env python3
"""Recover the verified PairIP emulator inputs without persisting the 1.1 GB XAPK."""
from __future__ import annotations

import hashlib
import json
import lzma
import shutil
import struct
import zipfile
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REV = ROOT / "reverse"
CACHE = Path.home() / ".cache" / "bus-recovery"
XAPK = CACHE / "bus-evo-1.27.42.xapk"
BASE = CACHE / "com.Ovilex.BusSimulator2023.apk"
CONFIG = CACHE / "config.arm64_v8a.apk"
OUT = REV / "pairip-inputs"
RUNTIME = CACHE / "runtime"

EXPECTED_APKS = {
    BASE: "3fdd3863d39e0e251cdfb7dbf421b595069e23681c9c4003c5db4eb8d3ffe388",
    CONFIG: "1ec029e920de71615d8b333a2a3dc2efaaec549ac121d96c632a28c4672d5d2f",
}
EXPECTED_FILES = {
    "AYum7gkZqbCjV2Br": "c0c6f91c1a4117846628387513d835a9f37657de6bf7193384eb487464856560",
    "ERzS3xEHg1Vs5U4O": "07b657a353e7ea2c3a36f61dc4b3f64f5cd9b7a0f36eb7bd08a5c31776b51155",
    "libil2cpp.so": "40c4ae6f4f2563ce0089e7a07055ff6e919ba0390b00610008c5c3fe6061cd61",
    "libpairipcore.so": "fa1d6af102b96fd9a79b86850cb935de16228ab26a0606e049c25bb986c6a7e2",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(4 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def raw_read(path: Path, info: zipfile.ZipInfo) -> bytes:
    """Read an entry while deliberately ignoring PairIP's forged ZIP CRCs."""
    with path.open("rb") as stream:
        stream.seek(info.header_offset)
        header = stream.read(30)
        fields = struct.unpack("<IHHHHHIIIHH", header)
        signature, _version, _flags, method, _time, _date, _crc, _cs, _us, name_len, extra_len = fields
        if signature != 0x04034B50:
            raise ValueError(f"bad local header for {info.filename}")
        stream.seek(name_len + extra_len, 1)
        data = stream.read(info.compress_size)
    if method == 0:
        output = data
    elif method == 8:
        output = zlib.decompress(data, -15)
    else:
        raise ValueError(f"unsupported compression method {method}")
    if len(output) != info.file_size:
        raise ValueError(f"size mismatch for {info.filename}")
    return output


def extract_apks() -> None:
    if not BASE.exists() or not CONFIG.exists():
        if not XAPK.exists():
            raise FileNotFoundError(
                f"{XAPK} is absent. Download the original 1.27.42 XAPK from "
                "https://d.apkpure.net/b/XAPK/com.Ovilex.BusSimulator2023?version=latest"
            )
        with zipfile.ZipFile(XAPK) as archive:
            for name in (BASE.name, CONFIG.name):
                (CACHE / name).write_bytes(archive.read(name))
    for path, expected in EXPECTED_APKS.items():
        actual = sha256(path)
        if actual != expected:
            raise ValueError(f"{path}: expected {expected}, got {actual}")


def extract_inputs() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    RUNTIME.mkdir(parents=True, exist_ok=True)
    sources = {
        BASE: {
            "assets/AYum7gkZqbCjV2Br": "AYum7gkZqbCjV2Br",
            "assets/ERzS3xEHg1Vs5U4O": "ERzS3xEHg1Vs5U4O",
        },
        CONFIG: {
            "lib/arm64-v8a/libil2cpp.so": "libil2cpp.so",
            "lib/arm64-v8a/libpairipcore.so": "libpairipcore.so",
        },
    }
    for apk, entries in sources.items():
        with zipfile.ZipFile(apk) as archive:
            for entry_name, output_name in entries.items():
                data = raw_read(apk, archive.getinfo(entry_name))
                actual = hashlib.sha256(data).hexdigest()
                if actual != EXPECTED_FILES[output_name]:
                    raise ValueError(f"{output_name}: expected {EXPECTED_FILES[output_name]}, got {actual}")
                if output_name == "libil2cpp.so":
                    with lzma.open(OUT / "libil2cpp.so.xz", "wb", preset=6) as compressed:
                        compressed.write(data)
                    (RUNTIME / output_name).write_bytes(data)
                else:
                    (OUT / output_name).write_bytes(data)
    metadata = {
        "source": "https://d.apkpure.net/b/XAPK/com.Ovilex.BusSimulator2023?version=latest",
        "version": "1.27.42 (242)",
        "apk_sha256": {path.name: expected for path, expected in EXPECTED_APKS.items()},
        "raw_file_sha256": EXPECTED_FILES,
    }
    (OUT / "source-hashes.json").write_text(json.dumps(metadata, indent=2) + "\n")
    for path in sorted(OUT.iterdir()):
        if path.is_file():
            print(f"{path.relative_to(ROOT)} {path.stat().st_size} bytes")
    print(f"Runtime IL2CPP: {RUNTIME / 'libil2cpp.so'}")


def restore_runtime_from_workspace() -> bool:
    compressed = OUT / "libil2cpp.so.xz"
    required = [compressed] + [OUT / name for name in EXPECTED_FILES if name != "libil2cpp.so"]
    if not all(path.exists() for path in required):
        return False
    RUNTIME.mkdir(parents=True, exist_ok=True)
    runtime_library = RUNTIME / "libil2cpp.so"
    with lzma.open(compressed, "rb") as source, runtime_library.open("wb") as target:
        shutil.copyfileobj(source, target, 4 << 20)
    actual = sha256(runtime_library)
    if actual != EXPECTED_FILES["libil2cpp.so"]:
        raise ValueError(f"decompressed IL2CPP hash mismatch: {actual}")
    for name in EXPECTED_FILES:
        if name != "libil2cpp.so" and sha256(OUT / name) != EXPECTED_FILES[name]:
            raise ValueError(f"persisted input hash mismatch: {name}")
    print(f"Restored runtime IL2CPP from workspace: {runtime_library}")
    return True


if __name__ == "__main__":
    if not restore_runtime_from_workspace():
        extract_apks()
        extract_inputs()
