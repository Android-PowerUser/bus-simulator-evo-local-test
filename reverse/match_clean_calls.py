#!/usr/bin/env python3
from pathlib import Path
from elftools.elf.elffile import ELFFile
from array import array
import collections, struct

BUS = Path('reverse/native/v8/lib/arm64-v8a/libil2cpp.so')
CLEAN = Path('reverse/clean-reference/pocket-mortys-libil2cpp-2022.3.62f2.so')
BUS_PLT = 0x50b8f20
BUS_GOT = 0x54662f0
BUS_STUBS = 577
CLEAN_PLT = 0x2e0f1d0
CLEAN_STUBS = 571
RADII=(12,10,8,6,5,4)

def norm(w):
    # AArch64 code is fixed-width. Remove address/layout immediates while retaining
    # opcode and register structure so equivalent code from another Unity game
    # can be matched reliably.
    if w & 0xfc000000 in (0x94000000,0x14000000):       # BL/B imm26
        return w & 0xfc000000
    if w & 0xff000010 == 0x54000000:                    # B.cond imm19
        return w & ~0x00ffffe0
    if w & 0x7e000000 == 0x34000000:                    # CBZ/CBNZ imm19
        return w & ~0x00ffffe0
    if w & 0x7e000000 == 0x36000000:                    # TBZ/TBNZ imm14
        return w & ~0x0007ffe0
    if w & 0x1f000000 == 0x10000000:                    # ADR/ADRP
        return w & ~0x60ffffe0
    if w & 0x3b000000 == 0x18000000:                    # literal load
        return w & ~0x00ffffe0
    if w & 0x1f000000 == 0x11000000:                    # ADD/SUB immediate
        return w & ~0x003ffc00
    if w & 0x3b000000 == 0x39000000:                    # load/store unsigned offset
        return w & ~0x003ffc00
    if w & 0x3b200c00 == 0x38000000:                    # load/store unscaled/pre/post
        return w & ~0x001ff000
    if w & 0x3a000000 == 0x28000000:                    # load/store pair
        return w & ~0x003f8000
    if w & 0x1f800000 == 0x12800000:                    # MOVN/MOVZ/MOVK
        return w & ~0x001fffe0
    return w

def branch_target(pc,w):
    if w & 0xfc000000 != 0x94000000:return None
    imm=w&0x03ffffff
    if imm&0x02000000:imm-=0x04000000
    return pc+(imm<<2)

def sections(path):
    result=[]
    with open(path,'rb') as f:
        elf=ELFFile(f)
        for sec in elf.iter_sections():
            if not (sec['sh_flags']&0x4) or sec.name=='.plt':continue
            data=sec.data()
            if len(data)<4:continue
            words=array('I');words.frombytes(data[:len(data)//4*4])
            if struct.pack('=I',1)!=struct.pack('<I',1):words.byteswap()
            norms=array('I',(norm(w) for w in words))
            result.append((sec.name,sec['sh_addr'],words,norms))
    return result

def load_reloc_slots(path,got,drop_execute=False):
    slots={}
    with open(path,'rb') as f:
        elf=ELFFile(f);sec=elf.get_section_by_name('.rela.plt');sym=elf.get_section(sec['sh_link'])
        for r in sec.iter_relocations():
            name=sym.get_symbol(r['r_info_sym']).name
            if drop_execute and name=='ExecuteProgram':continue
            d=r['r_offset']-got
            if d>=0 and d%8==0:slots[d//8]=name
    return slots

def clean_symbols(path):
    with open(path,'rb') as f:
        elf=ELFFile(f);sec=elf.get_section_by_name('.rela.plt');sym=elf.get_section(sec['sh_link'])
        return {i:sym.get_symbol(r['r_info_sym']).name for i,r in enumerate(sec.iter_relocations())}

pmap=load_reloc_slots(BUS,BUS_GOT,True);cmap=clean_symbols(CLEAN)
missing=set(range(BUS_STUBS))-set(pmap)
B=sections(BUS);C=sections(CLEAN)

calls=collections.defaultdict(list)
for sn,base,words,norms in B:
    for i,w in enumerate(words):
        t=branch_target(base+4*i,w)
        if t is not None and BUS_PLT<=t<BUS_PLT+16*BUS_STUBS and (t-BUS_PLT)%16==0:
            calls[(t-BUS_PLT)//16].append((sn,base,i))
print('known slots',len(pmap),'missing',len(missing),'missing called',sum(s in calls for s in missing),'calls to missing',sum(len(calls[s]) for s in missing))
for s in sorted(missing):
    if s in calls:print('CALL',s,len(calls[s]),','.join(hex(base+4*i) for sn,base,i in calls[s][:8]))

# Index only clean calls into its PLT, not millions of unrelated instructions.
index={r:collections.defaultdict(list) for r in RADII}
for sn,base,words,norms in C:
    for i,w in enumerate(words):
        t=branch_target(base+4*i,w)
        if t is None or not (CLEAN_PLT<=t<CLEAN_PLT+16*CLEAN_STUBS) or (t-CLEAN_PLT)%16:continue
        slot=(t-CLEAN_PLT)//16
        for r in RADII:
            if i>=r and i+r<len(words):
                key=norms[i-r:i+r+1].tobytes()
                index[r][key].append((sn,base,i,slot))
print('clean PLT call contexts', {r:sum(len(v) for v in index[r].values()) for r in RADII})

results={}
for slot in sorted(missing):
    votes=collections.Counter();ev=[]
    for bsn,bbase,bi in calls.get(slot,[]):
        bsec=next(x for x in B if x[0]==bsn);bn=bsec[3]
        for r in RADII:
            if bi<r or bi+r>=len(bn):continue
            key=bn[bi-r:bi+r+1].tobytes();matches=index[r].get(key,[])
            if len(matches)==1:
                csn,cbase,ci,cslot=matches[0];name=cmap[cslot]
                votes[name]+=1;ev.append((bbase+4*bi,cbase+4*ci,r,name,cslot));break
    if votes:
        results[slot]=(votes,ev)
print('\nMATCHED')
for s,(votes,ev) in sorted(results.items()):
    name,count=votes.most_common(1)[0];total=sum(votes.values());mark='OK' if count==total else 'CONFLICT'
    evidence=','.join(f'{a:x}->{b:x}/r{r}' for a,b,r,n,cs in ev if n==name)
    print(f'{s:3} {mark:8} {count}/{total} {name} evidence {evidence[:260]}')
print('matched slots',len(results),'of called missing',sum(i in calls for i in missing))
