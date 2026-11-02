#!/usr/bin/env python3
"""Resolve Unity frames only when symbol and executable GNU Build IDs match."""
import argparse, hashlib, json, subprocess, sys, urllib.request
from pathlib import Path
try:
    from elftools.elf.elffile import ELFFile
except ImportError:
    sys.path.insert(0, str(Path(__file__).resolve().parent/'pydeps'))
    from elftools.elf.elffile import ELFFile
URL='https://github.com/NextBep/AndroidNativeLibraries/releases/download/2022.3.62f2/libunity.sym.so.arm64-v8a'
SHA='0e0e970678e4993673b7ce70c1af658eadcdee24397e94978d3e879949b9acc6'
BUILD='78b0074646c115a2f68b3ef36fae57c676213fac'

def build_id(elf):
    for section in elf.iter_sections():
        if section['sh_type']=='SHT_NOTE':
            for note in section.iter_notes():
                if note['n_type']=='NT_GNU_BUILD_ID': return note['n_desc']
    return None

def symbolicate(symbols, addresses, expected_build_id):
    with Path(symbols).open('rb') as f:
        elf=ELFFile(f)
        actual=build_id(elf)
        if actual!=expected_build_id:
            raise ValueError(f'Build ID mismatch: expected {expected_build_id}, got {actual}')
        table=elf.get_section_by_name('.symtab')
        if table is None: raise ValueError('No symbol table in input')
        functions=[s for s in table.iter_symbols() if s['st_size'] and s['st_info']['type']=='STT_FUNC']
        result=[]
        for address in addresses:
            hits=[s for s in functions if s['st_value']<=address<s['st_value']+s['st_size']]
            record={'address':hex(address),'matches':[]}
            for s in hits:
                name=s.name
                try:name=subprocess.check_output(['c++filt',name],text=True).strip()
                except (OSError,subprocess.CalledProcessError):pass
                record['matches'].append({'symbol':s.name,'demangled':name,'offset':hex(address-s['st_value'])})
            result.append(record)
        return {'build_id':actual,'frames':result}

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--symbols',type=Path,default=Path(__file__).parent/'symbols/libunity-2022.3.62f2-arm64.sym.so')
    p.add_argument('--download',action='store_true')
    p.add_argument('--build-id',default=BUILD)
    p.add_argument('addresses',nargs='*',default=['0x9d6d20','0x9e1ff8','0x965c58'])
    a=p.parse_args()
    if a.download:
        data=urllib.request.urlopen(URL,timeout=90).read()
        if hashlib.sha256(data).hexdigest()!=SHA: raise ValueError('Downloaded symbol hash mismatch')
        a.symbols.parent.mkdir(parents=True,exist_ok=True);a.symbols.write_bytes(data)
    print(json.dumps(symbolicate(a.symbols,[int(x,0) for x in a.addresses],a.build_id),indent=2))
if __name__=='__main__':main()
