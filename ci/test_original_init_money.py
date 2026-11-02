import lzma,unittest,sys
from io import BytesIO
from pathlib import Path
from build_original_init_money import patch,ENTRY,CAVE
from elftools.elf.elffile import ELFFile
from unicorn import Uc,UC_ARCH_ARM64,UC_MODE_ARM
from unicorn.arm64_const import *
class OriginalInitMoneyTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  root=Path(__file__).resolve().parent.parent
  cls.raw=lzma.decompress((root/'reverse/pairip-inputs/libil2cpp.so.xz').read_bytes())
  cls.out,cls.report=patch(cls.raw)
 def test_only_two_declared_ranges_change(self):
  last=0
  for start,end in self.report['modified_file_ranges']:
   self.assertEqual(self.raw[last:start],self.out[last:start]);last=end
  self.assertEqual(self.raw[last:],self.out[last:])
 def test_original_initializer_not_got_resolver(self):
  # Original DT_INIT occupies the beginning of the same RX page as our cave.
  elf=ELFFile(BytesIO(self.raw))
  init=next(t.entry.d_val for t in elf.get_section_by_name('.dynamic').iter_tags() if t.entry.d_tag=='DT_INIT')
  segment=next(s for s in elf.iter_segments() if s['p_type']=='PT_LOAD' and s['p_vaddr']<=init<s['p_vaddr']+s['p_filesz'])
  offset=segment['p_offset']+init-segment['p_vaddr']
  self.assertEqual(self.raw[offset:offset+4],bytes.fromhex('5f2403d5'))
  self.assertEqual(self.raw[offset:offset+64],self.out[offset:offset+64])
 def test_call_abi(self):
  u=Uc(UC_ARCH_ARM64,UC_MODE_ARM)
  for va,(start,end) in zip([ENTRY,CAVE],self.report['modified_file_ranges']):
   u.mem_map(va&-4096,4096);u.mem_write(va,bytes(self.out[start:start+16]))
  for r,v in [(UC_ARM64_REG_X1,0xbad),(UC_ARM64_REG_X8,0x123),(UC_ARM64_REG_X30,0x456),(UC_ARM64_REG_SP,0x100000)]:u.reg_write(r,v)
  u.emu_start(ENTRY,ENTRY+8,count=10)
  for r,v in [(UC_ARM64_REG_X0,1000000),(UC_ARM64_REG_X1,0),(UC_ARM64_REG_X8,0x123),(UC_ARM64_REG_X30,0x456),(UC_ARM64_REG_SP,0x100000)]:self.assertEqual(u.reg_read(r),v)
 def test_wrong_source_rejected(self):
  with self.assertRaises(ValueError):patch(b'wrong')
