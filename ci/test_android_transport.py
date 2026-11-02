import unittest
from android_transport import transient_boot_disconnect

class BootTransportTests(unittest.TestCase):
    def test_missing_device_during_boot(self):
        self.assertTrue(transient_boot_disconnect(RuntimeError("ADB exit 1: adb: device 'emulator-5554' not found\n")))
    def test_offline(self):
        self.assertTrue(transient_boot_disconnect(RuntimeError('ADB exit 1: adb: device offline')))
    def test_no_blanket_runtime_retry(self):
        for value in ('Android did not become fully ready', 'ADB exit 1: Permission denied', 'ADB exit 1: SecurityException', 'SIGSEGV'):
            self.assertFalse(transient_boot_disconnect(RuntimeError(value)))
