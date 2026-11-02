#!/usr/bin/env python3
"""Restore a clobbered MethodInfo argument in the existing 1,000,000-money edit.
Experiments only until Android runtime verification. A stock-value control
isolates whether the two-instruction money edit causes the startup crash.
"""
import hashlib,json,struct,sys,zipfile
from pathlib import Path
from io import BytesIO
ROOT=Path(__file__).resolve().parent.parent;sys.path.insert(0,str(ROOT/'reverse/pydeps'))
from elftools.elf.elffile import ELFFile
EXPECTED='95c3102110f096a3711c80a977d3e9d07371bc4005eae42f1d854af8be978049'
ENTRY=0x26078f4;CAVE=0x5a08fc0
STOCK=bytes.fromhex('00e28452e1031faa')
def patch(data,stock_control=False):
 if hashlib.sha256(data).hexdigest()!=EXPECTED:raise ValueError('Unexpected v17 IL2CPP hash')
 elf=ELFFile(BytesIO(data));loads=[s for s in elf.iter_segments() if s['p_type']=='PT_LOAD']
 def offset(va):
  s=next(s for s in loads if s['p_vaddr']<=va<s['p_vaddr']+s['p_filesz']);return s['p_offset']+va-s['p_vaddr']
 a,c=offset(ENTRY),offset(CAVE);original=data[a:a+8]
 if original!=bytes.fromhex('00488852e001a072'):raise ValueError('Unexpected existing money patch')
 if data[c:c+16]!=bytes(16):raise ValueError('Resolver cave occupied')
 def branch(src,dst):
  d=dst-src
  if d%4 or not -(1<<27)<=d<(1<<27):raise ValueError('Branch range')
  return struct.pack('<I',0x14000000|((d>>2)&0x3ffffff))
 out=bytearray(data)
 if stock_control:out[a:a+8]=STOCK
 else:
  # Keep both instructions generating 1,000,000, then return to the original
  # mov x1,xzr before the Decimal conversion call. X8/SP/LR remain untouched.
  out[c:c+12]=original+branch(CAVE+8,ENTRY+4)
  out[a:a+8]=branch(ENTRY,CAVE)+STOCK[4:]
 return out,{'experimental':True,'stock_money_control':stock_control,'entry':hex(ENTRY),'cave':hex(CAVE),'source_sha256':EXPECTED,'sha256':hashlib.sha256(out).hexdigest(),'money_value':10000 if stock_control else 1000000,'restored_abi':'x1=0 at original call, x8/SP/LR preserved'}
if __name__=='__main__':
 src,dst=map(Path,sys.argv[1:3]);stock='--stock-control' in sys.argv[3:];report=None
 with zipfile.ZipFile(src) as z,zipfile.ZipFile(dst,'w',zipfile.ZIP_DEFLATED) as out:
  for info in z.infolist():
   if info.filename.startswith('META-INF/'):continue
   b=z.read(info)
   if info.filename=='lib/arm64-v8a/libil2cpp.so':b,report=patch(b,stock)
   out.writestr(info,b)
 if report is None:raise ValueError('Missing IL2CPP')
 dst.with_suffix('.money-abi.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))
