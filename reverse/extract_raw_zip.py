#!/usr/bin/env python3
import sys, zipfile, struct, zlib
from pathlib import Path

def raw_read(path,info):
    with open(path,'rb') as f:
        f.seek(info.header_offset)
        h=f.read(30)
        sig,ver,flags,method,mt,md,crc,cs,us,nl,xl=struct.unpack('<IHHHHHIIIHH',h)
        if sig != 0x04034b50: raise ValueError('bad local header')
        f.seek(nl+xl,1); data=f.read(info.compress_size)
    if method==0: out=data
    elif method==8: out=zlib.decompress(data,-15)
    else: raise ValueError('unsupported method '+str(method))
    if len(out)!=info.file_size: raise ValueError('size mismatch')
    return out

src=Path(sys.argv[1]); out=Path(sys.argv[2]); names=set(sys.argv[3:])
out.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(src) as z:
    for i in z.infolist():
        if not names or i.filename in names:
            p=out/i.filename; p.parent.mkdir(parents=True,exist_ok=True)
            p.write_bytes(raw_read(src,i))
