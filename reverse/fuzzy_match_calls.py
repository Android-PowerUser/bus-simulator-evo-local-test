#!/usr/bin/env python3
exec(open('reverse/match_clean_calls.py').read().split("pmap=load_reloc_slots")[0])
pmap=load_reloc_slots(BUS,BUS_GOT,True);cmap=clean_symbols(CLEAN)
B=sections(BUS);C=sections(CLEAN)
# all clean PLT calls
cc=[]
for sn,base,w,n in C:
 for i,x in enumerate(w):
  t=branch_target(base+4*i,x)
  if t is not None and CLEAN_PLT<=t<CLEAN_PLT+16*CLEAN_STUBS and (t-CLEAN_PLT)%16==0:
   cc.append((sn,base,i,(t-CLEAN_PLT)//16,w,n))
for slot,addrs in {92:[0x22f5508],93:[0x22f56e0],134:[0x2306b8c]}.items():
 print('\nSLOT',slot)
 for addr in addrs:
  for bsn,bbase,bw,bn in B:
   if bbase<=addr<bbase+4*len(bw):bi=(addr-bbase)//4;break
  scored=[];r=18
  for csn,cbase,ci,cslot,cw,cn in cc:
   if bi<r or bi+r>=len(bw) or ci<r or ci+r>=len(cw):continue
   # Centered Hamming score; nearby instructions matter more.
   eq=[];score=0
   for d in range(-r,r+1):
    if d==0:continue
    same=bn[bi+d]==cn[ci+d]
    eq.append(same)
    if same:score+=4 if abs(d)<=6 else 2 if abs(d)<=12 else 1
   scored.append((score,sum(eq),cmap[cslot],cbase+4*ci,cslot,eq))
  scored.sort(reverse=True)
  for x in scored[:20]:print('score',x[0],'eq',x[1],'/36','symbol',x[2],'at',hex(x[3]),'slot',x[4])
