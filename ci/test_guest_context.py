import sys,unittest,struct
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'reverse'))
from decode_guest_context import decode
class ContextDecoderTests(unittest.TestCase):
 def test_truncated_is_rejected(self):
  with self.assertRaises(ValueError):decode(bytes(100),'')
 def test_pc_is_checked_against_mapping(self):
  b=bytearray(4096);struct.pack_into('<Q',b,0x1b8,0x70002000)
  r=decode(b,"    00000000'70000000-00000000'70003fff r-x         0      4000  /data/test.so\n")
  self.assertTrue(r['pc_in_executable_mapping']);self.assertEqual(r['pc_library_relative'],'0x2000')
 def test_duplicate_full_file_mapping_does_not_shift_base(self):
  b=bytearray(4096);struct.pack_into('<Q',b,0x1b8,0x70002000)
  r=decode(b,"    00000000'10000000-00000000'10003fff r--         0      4000  /data/test.so\n    00000000'70000000-00000000'70003fff r--         0      4000  /data/test.so\n")
  self.assertEqual(r['pc_library_relative'],'0x2000')
 def test_wrong_context_cannot_be_called_executable(self):
  r=decode(bytes(4096),'')
  self.assertFalse(r['pc_in_executable_mapping'])
