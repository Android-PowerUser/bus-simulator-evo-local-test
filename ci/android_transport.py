"""Narrow boot-only ADB recovery policy; never excuses a runtime crash."""
def transient_boot_disconnect(error):
    text = str(error).lower()
    return text.startswith('adb exit ') and any(marker in text for marker in (
        "device 'emulator-5554' not found", 'device offline', 'device still authorizing'))
