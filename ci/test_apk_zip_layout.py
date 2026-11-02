import tempfile,unittest
from pathlib import Path
import test_apk_runtime_metadata as fixtures
from apk_zip_layout import require_identical_zip_prefix,signed_prefix_end
class ZipLayoutTests(unittest.TestCase):
 def pair(self,t):
  a,b=Path(t)/'a.apk',Path(t)/'b.apk'
  fixtures.RuntimeMetadataTests().apk(a,[(0x7109871a,b'old-authentication')])
  fixtures.RuntimeMetadataTests().apk(b,[(0x7109871a,b'different-new-authentication')])
  return a,b
 def test_only_signing_block_can_change(self):
  with tempfile.TemporaryDirectory() as t:
   a,b=self.pair(t);self.assertTrue(require_identical_zip_prefix(a,b)['raw_zip_prefix_unchanged'])
 def test_changed_raw_payload_rejected(self):
  with tempfile.TemporaryDirectory() as t:
   a,b=self.pair(t);raw=bytearray(b.read_bytes());raw[raw.index(b'unchanged')]=ord('X');b.write_bytes(raw)
   with self.assertRaises(ValueError):require_identical_zip_prefix(a,b)
 def test_moved_layout_rejected(self):
  with tempfile.TemporaryDirectory() as t:
   a,b=self.pair(t);b.write_bytes(b'offset-change'+b.read_bytes())
   with self.assertRaises(ValueError):require_identical_zip_prefix(a,b)
 def test_invalid_magic_rejected(self):
  with tempfile.TemporaryDirectory() as t:
   a,b=self.pair(t);b.write_bytes(b.read_bytes().replace(b'APK Sig Block 42',b'APK Sig Block XX'))
   with self.assertRaises(ValueError):signed_prefix_end(b)
