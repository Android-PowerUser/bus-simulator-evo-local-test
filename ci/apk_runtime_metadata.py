"""Preserve the application's opaque runtime data, not old authentication.
Only block 0xfa1cfabe is copied. Old APK signatures, source stamps and
other distribution-authentication records are deliberately NOT restored.
The current APK must still pass apksigner verification with its new signer.
"""
import hashlib,struct
from pathlib import Path
APP_METADATA_ID=0xfa1cfabe
MAGIC=b'APK Sig Block 42'
def parse(path):
 data=Path(path).read_bytes();position=data.rfind(b'PK\x05\x06',max(0,len(data)-65557))
 if position<0 or position+22>len(data):raise ValueError('Missing ZIP EOCD')
 comment=struct.unpack_from('<H',data,position+20)[0]
 if position+22+comment!=len(data):raise ValueError('Unsupported trailing ZIP data')
 cd=struct.unpack_from('<I',data,position+16)[0]
 if cd<24 or data[cd-16:cd]!=MAGIC:raise ValueError('Missing APK signing block')
 size=struct.unpack_from('<Q',data,cd-24)[0];start=cd-size-8
 if start<0 or size>64*1024*1024 or struct.unpack_from('<Q',data,start)[0]!=size:raise ValueError('Invalid APK block size')
 pairs=[];i=start+8
 while i<cd-24:
  if i+12>cd-24:raise ValueError('Truncated pair')
  n,ident=struct.unpack_from('<QI',data,i)
  if n<4 or i+8+n>cd-24:raise ValueError('Invalid pair size')
  pairs.append((ident,data[i+12:i+8+n]));i+=8+n
 return data,position,cd,start,pairs

def extract(path):
 pairs=parse(path)[4];records=[value for ident,value in pairs if ident==APP_METADATA_ID]
 if len(records)>1:raise ValueError('Duplicate application-metadata block')
 return records[0] if records else None

def restore(path,value):
 if value is None:return {'restored':False,'reason':'source has no application-metadata record'}
 data,eocd,cd,start,pairs=parse(path)
 if any(ident==APP_METADATA_ID for ident,_ in pairs):raise ValueError('Destination already has app metadata')
 pairs.append((APP_METADATA_ID,value))
 encoded=b''.join(struct.pack('<QI',len(v)+4,ident)+v for ident,v in pairs)
 size=len(encoded)+24
 block=struct.pack('<Q',size)+encoded+struct.pack('<Q',size)+MAGIC
 tail=bytearray(data[cd:]);struct.pack_into('<I',tail,eocd-cd+16,start+len(block))
 Path(path).write_bytes(data[:start]+block+tail)
 return {'restored':True,'id':hex(APP_METADATA_ID),'size':len(value),'sha256':hashlib.sha256(value).hexdigest(),'old_authentication_records_restored':False}
