# Independent native-loader control

Diagnostic only. No APK repair or gameplay result is implied.

- Source: https://github.com/zhkl0228/unidbg
- Pinned research checkout: `e0d88a900ae9d197c325af8d6a5875ee9958b724`.
- Uses Unidbg's ARM64 loader, JNI and bionic instead of handwritten Python PLT stubs.
- Resolver API23 is an explicit limitation, **not** the tested Android15 runtime.
- Only verified original APK/native/ERz inputs are used. New unresolved JNI calls fail closed rather than silently returning success.
- No installer or certificate identity is spoofed; no license response is provided.
- Initial objective: validate `JNI_OnLoad` under a second implementation; then enumerate the next genuinely required JNI/OS contracts.

Dependencies and generated classes live under `/home/user/.cache/unidbg-research`,
not in the repository. Build with Java17; the sandbox's original Java11 build
failed Maven TLS negotiation. The downloaded Temurin archive is SHA256 checked.

## Observed contracts

`JNI_OnLoad` ends at the real emulator return sentinel `0x7ffff0000`.
The probe independently checks this PC, rather than trusting Unidbg's generic
exception-to-minus-one fallback. The startup call does NOT return normally:
with a clean SLF4J1.7.36 API/simple binding, it reaches fork (Unidbg returns
ENOSYS), proc-file JNI, then an unmapped read at native+0x8d188. This differs
from the Android+0x55b3c crash and does not establish the same cause.
Also, the APK's minSdk is24, above this available API23 resolver.

Classpath must exclude every old SLF4J binding and API version, then include
exactly slf4j-api1.7.36 plus slf4j-simple1.7.36. Recursive Maven-cache JAR lists
without this filtering caused a misleading NoSuchMethodError.
The recorded clean startup log is in reports/controlled-startup-2026-11-02/
independent-native-model/startup-clean.log. No unmodeled JNI/license call is
silently converted to application success.
