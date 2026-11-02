"""Fail-closed raw ZIP-prefix invariance check across an APK re-sign operation."""
import hashlib,struct,zipfile
from pathlib import Path

def signed_prefix_end(path):
 with zipfile.ZipFile(path) as z:cd=z.start_dir
 with Path(path).open('rb') as f:
  f.seek(cd-24);footer=f.read(24)
  if len(footer)!=24 or footer[8:]!=b'APK Sig Block 42':raise ValueError('Missing APK signing block')
  n=struct.unpack('<Q',footer[:8])[0];start=cd-n-8
  if start<0:raise ValueError('Invalid block offset')
  f.seek(start)
  if f.read(8)!=footer[:8]:raise ValueError('Signing block size mismatch')
 return start

def require_identical_zip_prefix(before,after):
 a,b=signed_prefix_end(before),signed_prefix_end(after)
 if a!=b:raise ValueError('Re-signing moved APK signing-block offset')
 h=hashlib.sha256()
 with Path(before).open('rb') as x,Path(after).open('rb') as y:
  left=a
  while left:
   n=min(left,4*1024*1024);u,v=x.read(n),y.read(n)
   if len(u)!=n or u!=v:raise ValueError('Re-signing altered raw ZIP prefix')
   h.update(u);left-=n
 return {'raw_zip_prefix_unchanged':True,'prefix_size':a,'prefix_sha256':h.hexdigest(),'original_authentication_transplanted':False}
