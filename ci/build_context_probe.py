#!/usr/bin/env python3
"""Diagnostic only: preserve the guest ucontext before Unity forwards SIGSEGV.
Does not suppress a signal, change licensing or claim to repair the app.
"""
import hashlib,json,struct,subprocess,sys,tempfile,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(ROOT/'reverse/pydeps'))
from elftools.elf.elffile import ELFFile
from io import BytesIO
EXPECTED='8ee0b3b8faa4a0f11ac8daa2590ab6b8c6d4852c3ec35554f22c7163470c4221'
HOOK=0x9d6c64
PATH='/data/user/0/com.Ovilex.BusSimulator2023/unity-guest-ucontext.bin'
def patch(data):
    if hashlib.sha256(data).hexdigest()!=EXPECTED:raise ValueError('Unexpected Unity library: refusing probe patch')
    elf=ELFFile(BytesIO(data));loads=[s for s in elf.iter_segments() if s['p_type']=='PT_LOAD']
    note=next(i for i,s in enumerate(elf.iter_segments()) if s['p_type']=='PT_NOTE')
    load=next(s for s in loads if s['p_vaddr']<=HOOK<s['p_vaddr']+s['p_filesz'])
    hook_off=load['p_offset']+HOOK-load['p_vaddr']
    if data[hook_off:hook_off+4]!=bytes.fromhex('fe0f1df8'):raise ValueError('Hook prologue changed')
    align=0x4000;va=(max(s['p_vaddr']+s['p_memsz'] for s in loads)+align-1)&-align
    off=(len(data)+align-1)&-align
    assembly=f'''.text
.global probe
probe:
 sub sp, sp, #128
 stp x0, x1, [sp]
 stp x2, x3, [sp, #16]
 stp x4, x5, [sp, #32]
 stp x6, x7, [sp, #48]
 stp x8, x9, [sp, #64]
 stp x19, x20, [sp, #80]
 stp x30, xzr, [sp, #96]
 mrs x9, nzcv
 str x9, [sp, #112]
 mov x19, x2
 mov x0, #-100
 adr x1, filename
 mov x2, #577
 mov x3, #384
 mov x8, #56
 svc #0
 tbnz x0, #63, done
 mov x20, x0
 mov x1, x19
 mov x2, #4096
 mov x8, #64
 svc #0
 mov x0, x20
 mov x8, #57
 svc #0
done:
 ldr x9, [sp, #112]
 msr nzcv, x9
 ldp x0, x1, [sp]
 ldp x2, x3, [sp, #16]
 ldp x4, x5, [sp, #32]
 ldp x6, x7, [sp, #48]
 ldp x8, x9, [sp, #64]
 ldp x19, x20, [sp, #80]
 ldp x30, xzr, [sp, #96]
 add sp, sp, #128
 .inst 0xf81d0ffe
 b resume
filename:
 .asciz "{PATH}"
'''
    with tempfile.TemporaryDirectory() as tmp:
        tmp=Path(tmp);(tmp/'probe.S').write_text(assembly)
        subprocess.run(['aarch64-linux-gnu-as','-o',str(tmp/'probe.o'),str(tmp/'probe.S')],check=True)
        subprocess.run(['aarch64-linux-gnu-ld',f'-Ttext={hex(va)}',f'--defsym=resume={HOOK+4}', '-o',str(tmp/'probe.elf'),str(tmp/'probe.o')],check=True)
        subprocess.run(['aarch64-linux-gnu-objcopy','-O','binary','--only-section=.text',str(tmp/'probe.elf'),str(tmp/'probe.bin')],check=True)
        code=(tmp/'probe.bin').read_bytes()
    out=bytearray(data);out.extend(bytes(off-len(out)));out.extend(code)
    phoff=elf.header['e_phoff']+note*elf.header['e_phentsize']
    struct.pack_into('<IIQQQQQQ',out,phoff,1,5,off,va,va,len(code),len(code),align)
    delta=va-HOOK
    if delta%4 or not -(1<<27)<=delta<(1<<27):raise ValueError('Probe outside branch range')
    struct.pack_into('<I',out,hook_off,0x14000000|((delta>>2)&0x3ffffff))
    return out,{'diagnostic_only':True,'source_sha256':EXPECTED,'hook':hex(HOOK),'segment_vaddr':hex(va),'segment_offset':hex(off),'capture_path':PATH,'bytes':len(code),'sha256':hashlib.sha256(out).hexdigest()}
def main():
    src=Path(sys.argv[1]);dst=Path(sys.argv[2])
    with zipfile.ZipFile(src) as z,zipfile.ZipFile(dst,'w',zipfile.ZIP_DEFLATED) as out:
        report=None
        for info in z.infolist():
            if info.filename.startswith('META-INF/'):continue
            data=z.read(info)
            if info.filename=='lib/arm64-v8a/libunity.so':data,report=patch(data)
            out.writestr(info,data)
    if report is None:raise ValueError('Unity library absent')
    dst.with_suffix('.probe.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))
if __name__=='__main__':main()
