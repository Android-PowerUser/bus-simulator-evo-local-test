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
