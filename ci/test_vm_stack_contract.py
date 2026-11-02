"""The Java call-site line is APK evidence, not a guessed SDK reference."""
import re,unittest
from pathlib import Path
class VmStackContractTests(unittest.TestCase):
 def test_stock_invoke_execute_call_line_is_69(self):
  root=Path(__file__).resolve().parent.parent
  source=(root/'reverse/smali/stock/classes10/com/pairip/VMRunner.smali').read_text()
  method=source[source.index('.method public static invoke('):]
  method=method[:method.index('.end method')]
  call=method.index('invoke-static {v0, p1}, Lcom/pairip/VMRunner;->executeVM')
  self.assertEqual(int(re.findall(r'\.line (\d+)',method[:call])[-1]),69)
  emulator=(root/'reverse/emulate_pairip_vm.py').read_text()
  self.assertIn('"--invoke-stack-line", type=int, default=69',emulator)
