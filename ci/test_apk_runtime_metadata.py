import io,struct,tempfile,unittest,zipfile
from pathlib import Path
from apk_runtime_metadata import parse,extract,restore,MAGIC,APP_METADATA_ID
class RuntimeMetadataTests(unittest.TestCase):
 def apk(self,path,records):
  b=io.BytesIO()
  with zipfile.ZipFile(b,'w') as z:z.writestr('payload',b'unchanged')
  raw=b.getvalue();eo=raw.rfind(b'PK\x05\x06');cd=struct.unpack_from('<I',raw,eo+16)[0]
  encoded=b''.join(struct.pack('<QI',len(v)+4,i)+v for i,v in records);n=len(encoded)+24
  block=struct.pack('<Q',n)+encoded+struct.pack('<Q',n)+MAGIC
  tail=bytearray(raw[cd:]);struct.pack_into('<I',tail,eo-cd+16,cd+len(block));path.write_bytes(raw[:cd]+block+tail)
 def test_only_application_data_restored(self):
  with tempfile.TemporaryDirectory() as t:
   p=Path(t)/'app.apk';self.apk(p,[(0x7109871a,b'new-signature')]);original=parse(p)
   restore(p,b'opaque-runtime-data');new=parse(p)
   self.assertEqual(extract(p),b'opaque-runtime-data')
   self.assertEqual(new[0][:new[3]],original[0][:original[3]])
   self.assertEqual(new[4],[(0x7109871a,b'new-signature'),(APP_METADATA_ID,b'opaque-runtime-data')])
   with zipfile.ZipFile(p) as z:self.assertEqual(z.read('payload'),b'unchanged')
 def test_duplicate_data_rejected(self):
  with tempfile.TemporaryDirectory() as t:
   p=Path(t)/'app.apk';self.apk(p,[(APP_METADATA_ID,b'x')])
   with self.assertRaises(ValueError):restore(p,b'y')
 def test_invalid_input_rejected(self):
  with tempfile.TemporaryDirectory() as t:
   p=Path(t)/'bad.apk';p.write_bytes(b'bad')
   with self.assertRaises(ValueError):extract(p)
 def test_absent_metadata_not_invented(self):
  with tempfile.TemporaryDirectory() as t:
   p=Path(t)/'app.apk';self.apk(p,[(0x7109871a,b'new')]);before=p.read_bytes()
   self.assertIsNone(extract(p));self.assertFalse(restore(p,None)['restored']);self.assertEqual(before,p.read_bytes())
