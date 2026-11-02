#!/usr/bin/env python3
"""Compare APK payloads and signing-block structure without bypassing validation.
Reads original ZIP payloads even if their CRC fields are deliberately unusual.
No signature is accepted, forged, or patched by this audit.
"""
import argparse,hashlib,json,struct,zipfile
from pathlib import Path
from restore_pairip_inputs import raw_read
NAMES={0x7109871a:'APK Signature Scheme v2',0xf05368c0:'APK Signature Scheme v3',0x1b93ad61:'APK Signature Scheme v3.1',0x42726577:'verity padding',0x6dff800d:'source stamp'}
def signing_blocks(path):
 with Path(path).open('rb') as f:
  f.seek(0,2);size=f.tell();f.seek(max(0,size-65557));tail=f.read()
  pos=tail.rfind(b'PK\x05\x06')
  if pos<0:raise ValueError('No ZIP EOCD')
  cd=struct.unpack_from('<I',tail,pos+16)[0]
  if cd<24:return []
  f.seek(cd-24);footer=f.read(24)
  if footer[8:]!=b'APK Sig Block 42':return []
  blocksize=struct.unpack_from('<Q',footer)[0];start=cd-blocksize-8
  if start<0 or blocksize>64*1024*1024:raise ValueError('Invalid signing block size')
  f.seek(start);block=f.read(blocksize+8)
  if len(block)!=blocksize+8 or struct.unpack_from('<Q',block)[0]!=blocksize:raise ValueError('Mismatched signing block sizes')
  records=[];i=8;end=len(block)-24
  while i<end:
   if i+12>end:raise ValueError('Truncated signing block pair')
   n,ident=struct.unpack_from('<QI',block,i)
   if n<4 or i+8+n>end:raise ValueError('Invalid signing block pair size')
   data=block[i+12:i+8+n]
   records.append({'id':hex(ident),'name':NAMES.get(ident,'unidentified'),'size':len(data),'sha256':hashlib.sha256(data).hexdigest()})
   i+=8+n
  return records

def payload_hashes(path):
 hashes={}
 with zipfile.ZipFile(path) as z:
  for entry in z.infolist():
   if entry.filename.startswith('META-INF/') or entry.is_dir():continue
   if entry.filename in hashes:raise ValueError('Duplicate ZIP entry: '+entry.filename)
   hashes[entry.filename]=hashlib.sha256(raw_read(Path(path),entry)).hexdigest()
 return hashes

def audit(original,resigned):
 before,after=payload_hashes(original),payload_hashes(resigned)
 a,b=signing_blocks(original),signing_blocks(resigned)
 return {'original_sha256':hashlib.file_digest(open(original,'rb'),'sha256').hexdigest(),'resigned_sha256':hashlib.file_digest(open(resigned,'rb'),'sha256').hexdigest(),'original_blocks':a,'resigned_blocks':b,'removed_block_ids':sorted(set(x['id'] for x in a)-set(x['id'] for x in b)),'added_block_ids':sorted(set(x['id'] for x in b)-set(x['id'] for x in a)),'payload_entries_before':len(before),'payload_entries_after':len(after),'changed_payloads':[n for n in sorted(set(before)&set(after)) if before[n]!=after[n]],'removed_payloads':sorted(set(before)-set(after)),'added_payloads':sorted(set(after)-set(before)),'signature_validity_not_checked_by_this_parser':True}
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('original',type=Path);p.add_argument('resigned',type=Path);p.add_argument('--output',type=Path);args=p.parse_args();r=audit(args.original,args.resigned);text=json.dumps(r,indent=2)
 if args.output:args.output.write_text(text+'\n')
 print(text)
