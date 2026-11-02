import unittest
from process_identity import main_process
class ProcessIdentityTests(unittest.TestCase):
    def test_preserves_parent_when_watchdog_appears(self):
        self.assertEqual(main_process('PID PPID NAME\n4652 347 game\n5556 4652 game', 'game'), '4652')
    def test_no_process(self):
        self.assertEqual(main_process('PID PPID NAME\n2 1 other','game'),'')
    def test_ambiguous_roots_rejected(self):
        self.assertEqual(main_process('4652 347 game\n6666 347 game','game'),'')
    def test_replacement_not_hidden(self):
        self.assertEqual(main_process('6666 347 game\n7777 6666 game','game'),'6666')
