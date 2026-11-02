import sys,unittest,zipfile
from pathlib import Path
from io import BytesIO
R=Path(__file__).resolve().parent.parent;sys.path.insert(0,str(R/'reverse/pydeps'))
from build_money_abi_candidate import patch,ENTRY,CAVE
from elftools.elf.elffile import ELFFile
from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM
from unicorn.arm64_const import *
class MoneyAbiTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  with zipfile.ZipFile(R/'apk/candidate-v17-got-resolver-config.apk') as z:cls.raw=z.read('lib/arm64-v8a/libil2cpp.so')
  cls.loads=[s for s in ELFFile(BytesIO(cls.raw)).iter_segments() if s['p_type']=='PT_LOAD']
 def run_patch(self,stock):
  b,r=patch(self.raw,stock);u=Uc(UC_ARCH_ARM64,UC_MODE_ARM)
  for a in [ENTRY,CAVE]:
   s=next(s for s in self.loads if s['p_vaddr']<=a<s['p_vaddr']+s['p_filesz']);off=s['p_offset']+a-s['p_vaddr'];u.mem_map(a&-4096,4096);u.mem_write(a,bytes(b[off:off+16]))
  u.reg_write(UC_ARM64_REG_X1,0xbadbad);u.reg_write(UC_ARM64_REG_X8,0x123456);u.reg_write(UC_ARM64_REG_X30,0xabcdef);u.reg_write(UC_ARM64_REG_SP,0x100000)
  u.emu_start(ENTRY,ENTRY+8,count=10)
  self.assertEqual(u.reg_read(UC_ARM64_REG_X1),0)
  self.assertEqual(u.reg_read(UC_ARM64_REG_X8),0x123456);self.assertEqual(u.reg_read(UC_ARM64_REG_X30),0xabcdef);self.assertEqual(u.reg_read(UC_ARM64_REG_SP),0x100000)
  return u
 def test_million_value_preserves_methodinfo_null(self):self.assertEqual(self.run_patch(False).reg_read(UC_ARM64_REG_X0),1000000)
 def test_original_value_control(self):self.assertEqual(self.run_patch(True).reg_read(UC_ARM64_REG_X0),10000)
