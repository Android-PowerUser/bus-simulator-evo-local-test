"""Execute the hash-inspected original DT_INIT stub; do not infer its argument."""
import sys,unittest,struct
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'reverse/pydeps'))
from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM,UC_HOOK_CODE
from unicorn.arm64_const import UC_ARM64_REG_X0,UC_ARM64_REG_X1,UC_ARM64_REG_X2,UC_ARM64_REG_X3,UC_ARM64_REG_X30,UC_ARM64_REG_SP
# First 64 bytes from verified stock libil2cpp (SHA40c4ae6f...), VA0x5a08000.
STUB=bytes.fromhex('5f2403d5060080d2070880d2220080d2030080d200000090c12ffd90d0ffff90116a66f82100038be17bbfa90000078be103009120023fd6f07bc1a8c0035fd6')
class DtInitContractTests(unittest.TestCase):
 def test_original_stub_passes_target_load_base_not_null(self):
  base=0x10000000;entry=base+0x5a08000;execute=0x20000000;stack=0x30000000
  uc=Uc(UC_ARCH_ARM64,UC_MODE_ARM)
  uc.mem_map(entry,0x1000);uc.mem_write(entry,STUB)
  uc.mem_map(base+0x5a00000,0x1000);uc.mem_write(base+0x5a00000,struct.pack('<Q',execute))
  uc.mem_map(execute,0x1000);uc.mem_map(stack,0x1000)
  uc.reg_write(UC_ARM64_REG_SP,stack+0x800);uc.reg_write(UC_ARM64_REG_X30,0xdeadbeef)
  observed={}
  def hook(u,pc,size,user):
   if pc==execute:
    observed['asset']=u.reg_read(UC_ARM64_REG_X0)
    observed['argument0']=struct.unpack('<Q',u.mem_read(u.reg_read(UC_ARM64_REG_X1),8))[0]
    observed['count']=u.reg_read(UC_ARM64_REG_X2);observed['reserved']=u.reg_read(UC_ARM64_REG_X3)
    u.emu_stop()
  uc.hook_add(UC_HOOK_CODE,hook);uc.emu_start(entry,execute+4,count=30)
  self.assertEqual(observed,dict(asset=entry+0x40,argument0=base,count=1,reserved=0))
