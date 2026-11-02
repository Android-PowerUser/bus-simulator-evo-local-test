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
 # Asset packs are about a gigabyte: never read the entire APK just to find
 # a small footer record. Offsets and both block sizes remain checked.
 with Path(path).open('rb') as f:
  f.seek(0,2);file_size=f.tell();tail_start=max(0,file_size-65557)
  f.seek(tail_start);tail=f.read();position=tail.rfind(b'PK\x05\x06')
  if position<0 or position+22>len(tail):raise ValueError('Missing ZIP EOCD')
  if position+22+struct.unpack_from('<H',tail,position+20)[0]!=len(tail):raise ValueError('Unsupported trailing ZIP data')
  cd=struct.unpack_from('<I',tail,position+16)[0]
  if cd<24 or cd>tail_start+position:raise ValueError('Invalid central-directory offset')
  f.seek(cd-24);footer=f.read(24)
  if len(footer)!=24 or footer[8:]!=MAGIC:raise ValueError('Missing APK signing block')
  size=struct.unpack_from('<Q',footer)[0];start=cd-size-8
  if start<0 or size>64*1024*1024:raise ValueError('Invalid APK block size')
  f.seek(start)
  if struct.unpack('<Q',f.read(8))[0]!=size:raise ValueError('Invalid APK block size')
  record=None
  while f.tell()<cd-24:
   pos=f.tell()
   if pos+12>cd-24:raise ValueError('Truncated pair')
   n,ident=struct.unpack('<QI',f.read(12))
   if n<4 or pos+8+n>cd-24:raise ValueError('Invalid pair size')
   if ident==APP_METADATA_ID:
    if record is not None:raise ValueError('Duplicate application-metadata block')
    record=f.read(n-4)
   else:f.seek(n-4,1)
  return record

def restore(path,value):
 if value is None:return {'restored':False,'reason':'source has no application-metadata record'}
 data,eocd,cd,start,pairs=parse(path)
 if any(ident==APP_METADATA_ID for ident,_ in pairs):raise ValueError('Destination already has app metadata')
 # Keep the conventional final verity-padding pair last.
 index=next((i for i,(ident,_) in enumerate(pairs) if ident==0x42726577),len(pairs))
 pairs.insert(index,(APP_METADATA_ID,value))
 encoded=b''.join(struct.pack('<QI',len(v)+4,ident)+v for ident,v in pairs)
 size=len(encoded)+24
 block=struct.pack('<Q',size)+encoded+struct.pack('<Q',size)+MAGIC
 tail=bytearray(data[cd:]);struct.pack_into('<I',tail,eocd-cd+16,start+len(block))
 Path(path).write_bytes(data[:start]+block+tail)
 return {'restored':True,'id':hex(APP_METADATA_ID),'size':len(value),'sha256':hashlib.sha256(value).hexdigest(),'old_authentication_records_restored':False,'inserted_before_verity_padding':True}


def remove_application_metadata(path):
 # A negative control only: delete app data without changing any authentic
 # signer, source stamp, ZIP payload or runtime instruction.
 data,eocd,cd,start,pairs=parse(path)
 removed=[v for ident,v in pairs if ident==APP_METADATA_ID]
 if len(removed)!=1:raise ValueError('Expected one application-metadata record')
 kept=[(ident,v) for ident,v in pairs if ident!=APP_METADATA_ID]
 encoded=b''.join(struct.pack('<QI',len(v)+4,ident)+v for ident,v in kept)
 n=len(encoded)+24;block=struct.pack('<Q',n)+encoded+struct.pack('<Q',n)+MAGIC
 tail=bytearray(data[cd:]);struct.pack_into('<I',tail,eocd-cd+16,start+len(block))
 Path(path).write_bytes(data[:start]+block+tail)
 return {'removed_application_metadata_only':True,'sha256':hashlib.sha256(removed[0]).hexdigest(),'size':len(removed[0]),'original_authentication_records_unmodified':True}
