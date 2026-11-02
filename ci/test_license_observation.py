import unittest
from license_observation import license_block_seen
class LicenseObservationTests(unittest.TestCase):
    def test_direct_license_ui(self):
        self.assertTrue(license_block_seen('game','game/com.pairip.licensecheck.LicenseActivity',''))
    def test_redirect_history(self):
        self.assertTrue(license_block_seen('game','com.android.vending/UnauthenticatedMainActivity','wm_create_activity: game/com.pairip.licensecheck.LicenseActivity'))
    def test_unrelated_app_rejected(self):
        self.assertFalse(license_block_seen('game','game/Main','other/com.pairip.licensecheck.LicenseActivity'))
    def test_normal_onboarding(self):
        self.assertFalse(license_block_seen('game','game/Main','game/Main'))
