import sys,struct,unittest,zipfile
from pathlib import Path
R=Path(__file__).resolve().parent.parent;sys.path.insert(0,str(R/'reverse/pydeps'))
from build_generic_guard import patch,ENTRY,CAVE
from elftools.elf.elffile import ELFFile
from io import BytesIO
from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM,UC_HOOK_CODE
from unicorn.arm64_const import *
class GenericGuardTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  with zipfile.ZipFile(R/'apk/candidate-v17-got-resolver-config.apk') as z:cls.raw=z.read('lib/arm64-v8a/libil2cpp.so')
  cls.patched,cls.report=patch(cls.raw)
  cls.loads=[s for s in ELFFile(BytesIO(cls.raw)).iter_segments() if s['p_type']=='PT_LOAD']
 def run_case(self,container,inst):
  u=Uc(UC_ARCH_ARM64,UC_MODE_ARM)
  for address in [ENTRY,CAVE]:
   s=next(s for s in self.loads if s['p_vaddr']<=address<s['p_vaddr']+s['p_filesz']);off=s['p_offset']+address-s['p_vaddr'];start=address&-4096;u.mem_map(start,4096);u.mem_write(address,bytes(self.patched[off:off+32]))
  u.mem_map(0x10000000,4096);u.mem_map(0x20000000,4096)
  u.reg_write(UC_ARM64_REG_SP,0x10000800);u.reg_write(UC_ARM64_REG_X0,container);u.reg_write(UC_ARM64_REG_X1,inst);u.reg_write(UC_ARM64_REG_X30,0x20000000)
  reached=[]
  def hook(u,pc,size,user):
   if pc in (ENTRY+4,0x20000000):reached.append(pc);u.emu_stop()
  u.hook_add(UC_HOOK_CODE,hook);u.emu_start(ENTRY,0x20000004,count=20)
  return u,reached
 def test_null_container_returns_unavailable(self):
  u,r=self.run_case(0,0x1234);self.assertEqual(r,[0x20000000]);self.assertEqual(u.reg_read(UC_ARM64_REG_X0),0);self.assertEqual(u.reg_read(UC_ARM64_REG_SP),0x10000800)
 def test_null_inst_preserves_existing_nullable_behavior(self):
  u,r=self.run_case(0x1234,0);self.assertEqual(r,[0x20000000]);self.assertEqual(u.reg_read(UC_ARM64_REG_X0),0)
 def test_valid_inputs_reach_original_body(self):
  u,r=self.run_case(0x1234,0x5678);self.assertEqual(r,[ENTRY+4]);self.assertEqual(u.reg_read(UC_ARM64_REG_X0),0x1234);self.assertEqual(u.reg_read(UC_ARM64_REG_X1),0x5678);self.assertEqual(u.reg_read(UC_ARM64_REG_SP),0x10000800-0x60)
