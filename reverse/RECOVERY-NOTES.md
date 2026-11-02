# PairIP emulator recovery state

## Verified results

- Original APKPure base/config APKs are byte-identical to the historical stock files:
  - base: `3fdd3863d39e0e251cdfb7dbf421b595069e23681c9c4003c5db4eb8d3ffe388`
  - ARM64 config: `1ec029e920de71615d8b333a2a3dc2efaaec549ac121d96c632a28c4672d5d2f`
- The SDK-35 combined run executed successfully up to the existing bounded guard: 5,844 dispatches, 7,739,907 instructions, `openat` length `0xffffaa4a`, no target IL2CPP accesses. SDK 35 therefore does not change the baseline.
- `LDRSH` makes `0xffffaa4a` equal signed -21942. The inline length is raw VM offset `0x1bfd1`; neither it nor path variable `0x161a0` is ever written before use.
- The preserved v11 device crash is the same native failure at `libpairipcore.so+0x55b3c`, with the same invalid path and expected hash. It faults after 996 iterations; the emulator guard stops before that invalid access.
- Device logcat shows only `libpairipcore.so` loaded from the app during ERz. The emulator now hides `libmain`, `libunity`, and `libil2cpp` during startup. This changes the run to 5,762 dispatches/7,640,166 instructions but not the final guard.
- Both `Exception.getStackTrace()` calls enumerate every supplied frame. The old two-frame array is therefore incomplete for startup. No `strcmp`/`strncmp` comparison is made on these strings.
- Stock and v8 differ materially: v8 replaces `StartupLauncher.launch()` with three NOPs. AYum reached in a v8-derived run does not prove that stock ERz completed in that run.

## Prepared but not executed

`emulate_pairip_vm.py` now has `--startup-stack short|framework|framework-core`.
The default `short` preserves the baseline. The other profiles add the Android 15 startup chain only during ERz, based on `android-15.0.0_r1` and device-logcat line numbers. `framework-core` additionally includes AndroidX CoreComponentFactory. The correct profile must be confirmed from the base manifest before treating it as authoritative.

`restore_pairip_inputs.py` verifies the original APKs and persists compact emulator inputs under `reverse/pairip-inputs/`; the 94 MB IL2CPP library is stored as xz and decompressed into `~/.cache/bus-recovery/runtime/`.

## Immediate recovery steps

The sandbox became unresponsive after a full JADX resource decode of the 60 MB base APK. Do not repeat that decode. After shell recovery:

1. If necessary, download `https://d.apkpure.net/b/XAPK/com.Ovilex.BusSimulator2023?version=latest` to `~/.cache/bus-recovery/bus-evo-1.27.42.xapk`.
2. Run `python3 reverse/restore_pairip_inputs.py`.
3. Parse only `AndroidManifest.xml` from the base APK (for example with Androguard), determine whether AndroidX CoreComponentFactory is present, then run the corresponding stack profile.
4. Keep the hash guard, do not force control-flow targets, and do not special-case the invalid pointer.
5. For an unpatched-library control use `--library reverse/pairip-inputs/libpairipcore.so --emulate-original-tls`. The default v18 resolver still has to be restored from the documented formula if the exact original comparison command is required.
