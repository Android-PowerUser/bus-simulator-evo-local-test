#!/usr/bin/env python3
"""Experimental, narrowly scoped null guard for optional full generic sharing.
Not a verified repair. Existing fully-shared lookup returns NULL for unavailable
instantiations; this hypothesis also rejects an absent metadata container.
It does not bypass licensing or suppress signals.
"""
import hashlib,json,struct,sys,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'reverse/pydeps'))
from elftools.elf.elffile import ELFFile
from io import BytesIO
ENTRY=0x235e66c;CAVE=0x5a08fe0

def patch(data):
 e=ELFFile(BytesIO(data));loads=[s for s in e.iter_segments() if s['p_type']=='PT_LOAD']
 def offset(va):
  s=next(s for s in loads if s['p_vaddr']<=va<s['p_vaddr']+s['p_filesz']);return s['p_offset']+va-s['p_vaddr']
 entry,cave=offset(ENTRY),offset(CAVE)
 prologue=bytes.fromhex('fd7bbaa9')
 if data[entry:entry+4]!=prologue:raise ValueError('GetFullySharedInst prologue mismatch')
 if data[cave:cave+32]!=bytes(32):raise ValueError('Resolver page tail is not empty')
 def branch(src,dst):
  delta=dst-src
  if delta%4 or not -(1<<27)<=delta<(1<<27):raise ValueError('Branch range')
  return 0x14000000|((delta>>2)&0x3ffffff)
 words=[0xb4000080,0xb4000061,struct.unpack('<I',prologue)[0],branch(CAVE+12,ENTRY+4),0xaa1f03e0,0xd65f03c0]
 result=bytearray(data);struct.pack_into('<I',result,entry,branch(ENTRY,CAVE));struct.pack_into('<6I',result,cave,*words)
 return result,{'experimental_not_verified':True,'entry':hex(ENTRY),'guard':hex(CAVE),'source_sha256':hashlib.sha256(data).hexdigest(),'sha256':hashlib.sha256(result).hexdigest(),'hypothesis':'Skip optional fully-shared lookup when genericContainer or inst is NULL; preserve original nonnull path.'}
if __name__=='__main__':
 src,dst=map(Path,sys.argv[1:3]);report=None
 with zipfile.ZipFile(src) as z,zipfile.ZipFile(dst,'w',zipfile.ZIP_DEFLATED) as out:
  for info in z.infolist():
   if info.filename.startswith('META-INF/'):continue
   b=z.read(info)
   if info.filename=='lib/arm64-v8a/libil2cpp.so':b,report=patch(b)
   out.writestr(info,b)
 if report is None:raise ValueError('Missing IL2CPP')
 dst.with_suffix('.guard.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))
