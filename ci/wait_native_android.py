"""Bounded boot gate: reject missing Binder/ADB and any ABI translation."""
import json,subprocess,time
from pathlib import Path
D=Path('runtime-results');D.mkdir(exist_ok=True)
deadline=time.monotonic()+240
while time.monotonic()<deadline:
 subprocess.run(['adb','connect','127.0.0.1:5555'],timeout=15,check=False)
 r=subprocess.run(['adb','-s','127.0.0.1:5555','shell','getprop sys.boot_completed; getprop ro.product.cpu.abilist; getprop ro.dalvik.vm.native.bridge'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=15)
 print(r.stdout,flush=True)
 lines=r.stdout.splitlines()
 if r.returncode==0 and lines and lines[0].strip()=='1':
  abi=lines[1].strip() if len(lines)>1 else '';bridge=lines[2].strip() if len(lines)>2 else ''
  if 'arm64-v8a' not in abi or bridge not in ('','0'):raise RuntimeError('Not genuine untranslated ARM64 Android')
  (D/'native-boot.json').write_text(json.dumps({'booted':True,'supported_abis':abi,'native_bridge':bridge,'gameplay_verified':False},indent=2));break
 time.sleep(5)
else:raise RuntimeError('Native Android container failed to boot; not an APK regression result')
