import unittest
from runtime_verdict import verify_runtime

class RuntimeVerdictTests(unittest.TestCase):
    def setUp(self):
        self.s = dict(game_installed=True, control_launched=True,
                      app_survived_120s=True, foreground_is_game=True,
                      game_fatal_crash_seen=False, system_server_pid_before='575',
                      system_server_pid_after='575', app_pid_at_15s='4304',
                      app_pid_at_45s='4304', app_pid_at_120s='4304')
    def test_healthy_start(self):
        self.assertTrue(verify_runtime(self.s, 'Status: ok'))
    def test_rejects_restart(self):
        self.s['app_pid_at_45s']='9999'
        self.assertFalse(verify_runtime(self.s, 'Status: ok'))
    def test_rejects_framework_restart(self):
        self.s['system_server_pid_after']='9999'
        self.assertFalse(verify_runtime(self.s, 'Status: ok'))
    def test_rejects_crash(self):
        self.s['game_fatal_crash_seen']=True
        self.assertFalse(verify_runtime(self.s, 'Status: ok'))
    def test_rejects_launcher_only_success(self):
        self.s['app_survived_120s']=False
        self.assertFalse(verify_runtime(self.s, 'Status: ok'))
    def test_rejects_license_screen(self):
        self.s['foreground_activity']='com.Ovilex.BusSimulator2023/com.pairip.licensecheck.LicenseActivity'
        self.assertFalse(verify_runtime(self.s, 'Status: ok'))
    def test_rejects_empty_result(self):
        self.assertFalse(verify_runtime({}, 'Status: ok'))
    def test_rejects_launch_error(self):
        self.assertFalse(verify_runtime(self.s, 'Error: Activity not found'))

if __name__=='__main__': unittest.main()
