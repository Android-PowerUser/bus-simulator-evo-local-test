import sys,unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'reverse'))
from emulation_contract import run_until_return
class FakeUc:
 def __init__(self,pc):self.pc=pc;self.calls=[]
 def emu_start(self,*args,**kwargs):self.calls.append((args,kwargs))
 def reg_read(self,_):return self.pc
class PhaseContractTests(unittest.TestCase):
 def test_real_return_required(self):
  u=FakeUc(0x5000);run_until_return(u,0x1000,0x5000,100,42,'startup')
  self.assertEqual(u.calls,[((0x1000,0x5000),{'count':100})])
 def test_budget_cannot_masquerade_as_return(self):
  with self.assertRaisesRegex(RuntimeError,'No next phase executed'):run_until_return(FakeUc(0x1234),0x1000,0x5000,100,42,'startup')
 def test_unbounded_budget_rejected(self):
  with self.assertRaises(ValueError):run_until_return(FakeUc(0x5000),0x1000,0x5000,0,42,'startup')
