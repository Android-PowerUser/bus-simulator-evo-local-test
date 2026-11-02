#!/usr/bin/env python3
"""Money-only experiment: preserve original PairIP/DT_INIT and all data.
No checks, license responses, signatures or initializers are bypassed.
The APK must subsequently be signed consistently with its split set.
"""
import hashlib,json,struct,sys,zipfile
from io import BytesIO
from pathlib import Path
ROOT=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'reverse/pydeps'))
from elftools.elf.elffile import ELFFile
EXPECTED='40c4ae6f4f2563ce0089e7a07055ff6e919ba0390b00610008c5c3fe6061cd61'
ENTRY=0x26078f4;CAVE=0x5a08fc0
STOCK=bytes.fromhex('00e28452e1031faa')
def patch(data):
 if hashlib.sha256(data).hexdigest()!=EXPECTED:raise ValueError('Expected exact signed-original IL2CPP content')
 elf=ELFFile(BytesIO(data));loads=[s for s in elf.iter_segments() if s['p_type']=='PT_LOAD']
 def offset(va):
  s=next(s for s in loads if s['p_vaddr']<=va<s['p_vaddr']+s['p_filesz']);return s['p_offset']+va-s['p_vaddr']
 a,c=offset(ENTRY),offset(CAVE)
 if data[a:a+8]!=STOCK or data[c:c+16]!=bytes(16):raise ValueError('Unexpected source instructions or occupied cave')
 def branch(src,dst):
  delta=dst-src
  if delta%4 or not -(1<<27)<=delta<(1<<27):raise ValueError('Branch outside AArch64 range')
  return struct.pack('<I',0x14000000|((delta>>2)&0x3ffffff))
 out=bytearray(data)
 out[c:c+12]=bytes.fromhex('00488852e001a072')+branch(CAVE+8,ENTRY+4)
 out[a:a+8]=branch(ENTRY,CAVE)+STOCK[4:]
 return out,{'experimental':True,'source_sha256':EXPECTED,'sha256':hashlib.sha256(out).hexdigest(),'money_value':1000000,'original_dt_init_preserved':True,'data_sections_unmodified':True,'modified_file_ranges':[[a,a+8],[c,c+12]],'license_checks_bypassed':False}
def build(src,dst):
 report=None
 with zipfile.ZipFile(src) as z,zipfile.ZipFile(dst,'w',zipfile.ZIP_DEFLATED) as out:
  for info in z.infolist():
   if info.filename.startswith('META-INF/'):continue
   data=z.read(info)
   if info.filename=='lib/arm64-v8a/libil2cpp.so':data,report=patch(data)
   out.writestr(info,data)
 if report is None:raise ValueError('No IL2CPP in config APK')
 return report
if __name__=='__main__':
 report=build(*sys.argv[1:3]);Path(sys.argv[2]).with_suffix('.original-init.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))
