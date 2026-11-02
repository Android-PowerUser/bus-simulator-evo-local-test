#!/usr/bin/env python3
"""Decode Android AArch64 ucontext captured before Unity's signal forwarding.
Android arm64 ucontext has mcontext at 0xb0; independently check PC against
mapped executable pages. This is not valid for x86 host ucontext.
"""
import argparse,json,re,struct
from pathlib import Path

def decode(data, maps_text):
    if len(data)<0x1c8:raise ValueError('Truncated AArch64 ucontext')
    q=lambda o:struct.unpack_from('<Q',data,o)[0]
    registers={f'x{i}':q(0xb8+i*8) for i in range(31)}
    registers.update(sp=q(0x1b0),pc=q(0x1b8),pstate=q(0x1c0))
    maps=[]
    for line in maps_text.splitlines():
        m=re.match(r'\s*(?:--->)?([0-9a-fA-F\']+)-([0-9a-fA-F\']+)\s+([rwxps-]+)\s+([0-9a-fA-F]+)\s+\S+\s*(.*)',line)
        if m:maps.append({'start':int(m[1].replace("'",''),16),'end':int(m[2].replace("'",''),16)+1,'permissions':m[3],'offset':int(m[4],16),'description':m[5]})
    pc=registers['pc'];hits=[x for x in maps if x['start']<=pc<x['end']]
    # Native bridge may map an entire ELF once for inspection, then map its
    # loadable segments again. Select the nearest matching zero-offset mapping,
    # not the first occurrence (which yields a bogus >4 GiB relative address).
    libraries={}
    for line in maps:
        if line['offset']==0 and '.so' in line['description'] and line['start']<=pc:
            libraries[line['description']]=max(line['start'],libraries.get(line['description'],0))
    result={'bytes':len(data),'layout':'Android AArch64 ucontext / sigcontext at 0xb0','fault_address_from_context_not_authoritative':hex(q(0xb0)), 'registers':{k:hex(v) for k,v in registers.items()},'pc_mappings':hits,'pc_in_executable_mapping':any('x' in x['permissions'] for x in hits)}
    for hit in hits:
        if hit['description'] in libraries:
            result['pc_library_relative']=hex(pc-libraries[hit['description']])
            result['pc_library_base']=hex(libraries[hit['description']])
    result['native_bridge_note']='Translated ARM64 text can be host-mapped r--; validate instruction permissions against guest ELF program headers, not host execute permission alone.'
    return result
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('context',type=Path);p.add_argument('tombstone',type=Path);a=p.parse_args()
    print(json.dumps(decode(a.context.read_bytes(),a.tombstone.read_text()),indent=2))
