import json,os,subprocess,time,traceback,zipfile,shutil,hashlib,threading
from pathlib import Path
R=Path(os.environ.get('GITHUB_WORKSPACE','.'));D=R/'runtime-results';D.mkdir(exist_ok=True)
A=os.environ.get('ANDROID_HOME','/usr/local/lib/android/sdk')+'/platform-tools/adb'
SERIAL=os.environ.get('ANDROID_SERIAL','emulator-5554')
PKG='com.Ovilex.BusSimulator2023';ACT=PKG+'/com.google.firebase.MessagingUnityPlayerActivity'
status={'release_tag':os.environ['TEST_RELEASE_TAG'],'environment':'GitHub Actions Linux / KVM','android_serial':SERIAL,'control_installed':False,'control_launched':False,'game_installed':False,'game_launch_attempted':False,'gameplay_verified':False,'state':'waiting_for_android'}
def save(): (D/'status.json').write_text(json.dumps(status,indent=2))
def adb(args,timeout=30,check=True):
 print(time.strftime('%H:%M:%S'),'ADB',args,flush=True)
 r=subprocess.run([A,'-s',SERIAL,*args],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=timeout)
 print(r.stdout,flush=True)
 if check and r.returncode:raise RuntimeError(f'ADB exit {r.returncode}: {r.stdout}')
 return r.stdout.strip()
def shell(cmd,timeout=30,check=True):return adb(['shell',cmd],timeout,check)
def adb_to_file(args,out_path,timeout=180):
 r=subprocess.run([A,'-s',SERIAL,*args],stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=timeout)
 Path(out_path).write_bytes(r.stdout)
 print(time.strftime('%H:%M:%S'),'ADB->file',args,r.returncode,len(r.stdout),r.stderr[:200],flush=True)
 return r.returncode,len(r.stdout)
def screen(name):
 with (D/name).open('wb') as f:subprocess.run([A,'-s',SERIAL,'exec-out','screencap','-p'],stdout=f,timeout=30,check=True)
def dump_il2cpp_got_early():
 # PairIP's injected DT_INIT repairs an intentionally sparse/scrambled PLT/GOT
 # before ordinary IL2CPP constructors run. Capture that short-lived state.
 records=[];seen=False;misses=0;deadline=time.monotonic()+35
 try:
  while time.monotonic()<deadline:
   probe=shell("p=$(pidof "+PKG+"); if [ -n \"$p\" ]; then echo PID=$p; grep 'libil2cpp.so' /proc/$p/maps; fi",5,False)
   lines=probe.splitlines();pid='';base=None
   for line in lines:
    if line.startswith('PID='):pid=line[4:].split()[0]
    elif 'libil2cpp.so' in line:
     parts=line.split()
     if len(parts)>=3 and parts[2]=='00000000':base=int(parts[0].split('-')[0],16)
   if not pid or base is None:
    if seen:
     misses+=1
     if misses>=4:break
    time.sleep(.04);continue
   seen=True;misses=0
   if not records:(D/'il2cpp-early-maps.txt').write_text(probe)
   # The protected library's .got.plt is at VA 0x54662d8. Two pages
   # beginning at 0x5466000 contain every live slot needed for recovery.
   start=base+0x5466000
   name='il2cpp-got-%03d.bin'%len(records)
   rc,size=adb_to_file(['exec-out','su','0','dd','if=/proc/'+pid+'/mem','bs=4096','skip='+str(start//4096),'count=2'],D/name,5)
   data=(D/name).read_bytes() if (D/name).exists() else b''
   sentinel=data[0x818:0x820].hex() if len(data)>=0x820 else ''
   records.append({'name':name,'pid':pid,'base':hex(base),'vaddr':hex(start),'bytes':size,'exit':rc,'sentinel_slot_165':sentinel,'t':round(time.monotonic(),6)})
   # Once the replacement initializer has populated the sparse GOT, sample the
   # IL2CPP data/BSS span used by metadata initialization. This distinguishes
   # missing PairIP data repair from a bad import identity without slowing every
   # high-frequency GOT capture.
   if len(records) in (2,6,10,14) and sentinel and sentinel!='0000000000000000':
    data_start=base+0x553c000
    data_name='il2cpp-data-%03d.bin'%len(records)
    drc,dsize=adb_to_file(['exec-out','su','0','dd','if=/proc/'+pid+'/mem','bs=4096','skip='+str(data_start//4096),'count=680'],D/data_name,12)
    records[-1]['data_sample']={'name':data_name,'vaddr':hex(data_start),'bytes':dsize,'exit':drc}
   if len(records)>=40:break
   time.sleep(.015)
 except Exception as e:
  records.append({'error':type(e).__name__+': '+str(e)})
 (D/'il2cpp-got-capture.json').write_text(json.dumps(records,indent=2))
 status['il2cpp_got_snapshots']=len([x for x in records if 'name' in x]);save()
def install_and_verify(label,args,package,min_paths,timeout):
 before=shell('pidof system_server')
 started=time.monotonic()
 try:result=adb(args,timeout)
 finally:
  status[label+'_install_seconds']=round(time.monotonic()-started,3)
  status['system_server_pid_after_'+label+'_install']=shell('pidof system_server',30,False)
  save()
 after=status['system_server_pid_after_'+label+'_install']
 if not before or after!=before:raise RuntimeError('system_server changed during '+label+' install: '+before+' -> '+after)
 if 'Success' not in result:raise RuntimeError(label+' install did not report Success')
 paths=[line[8:] for line in shell('pm path '+package).splitlines() if line.startswith('package:')]
 status[label+'_package_paths']=paths;save()
 if len(paths)<min_paths:raise RuntimeError(label+' package verification found '+str(len(paths))+' paths; expected at least '+str(min_paths))
 return result
def resign_test_apks(apks,keystore):
 tools=sorted((Path(os.environ['ANDROID_HOME'])/'build-tools').glob('*/apksigner'))
 if not tools:raise RuntimeError('apksigner not found')
 signer=str(tools[-1]);password=os.environ.get('TEST_KEYSTORE_PASSWORD','changeit');alias=os.environ.get('TEST_KEY_ALIAS','repaired')
 started=time.monotonic()
 for apk in map(Path,apks):
  out=apk.with_suffix('.resigned.apk');out.unlink(missing_ok=True)
  print(time.strftime('%H:%M:%S'),'RESIGN',apk.name,flush=True)
  subprocess.run([signer,'sign','--ks',str(keystore),'--ks-pass','pass:'+password,'--key-pass','pass:'+password,'--ks-key-alias',alias,'--v1-signing-enabled','true','--v2-signing-enabled','true','--v3-signing-enabled','true','--out',str(out),str(apk)],timeout=300,check=True)
  out.replace(apk)
  subprocess.run([signer,'verify','--verbose','--print-certs',str(apk)],timeout=60,check=True)
 status['all_apks_resigned']=True;status['resign_seconds']=round(time.monotonic()-started,3);save()
log=None
try:
 save();adb(['wait-for-device'],180)
 end=time.monotonic()+240
 while time.monotonic()<end:
  try:
   ready=shell('getprop sys.boot_completed; pm path android; service check media.audio_policy',20)
   if ready.startswith('1\n') and 'package:/system/' in ready and 'media.audio_policy: found' in ready:break
  except subprocess.TimeoutExpired:pass
  time.sleep(3)
 else:raise RuntimeError('Android did not become fully ready')
 adb(['root'],30,False);time.sleep(3);adb(['wait-for-device'],30)
 log_file=(D/'continuous-logcat.txt').open('w')
 log=subprocess.Popen([A,'-s',SERIAL,'logcat','-b','all','-v','threadtime'],stdout=log_file,stderr=subprocess.STDOUT)
 status['system_server_pid_before']=shell('pidof system_server')
 status['supported_abis']=shell('getprop ro.product.cpu.abilist')
 status['native_bridge']=shell('getprop ro.dalvik.vm.native.bridge')
 status['android_sdk']=shell('getprop ro.build.version.sdk')
 shell('settings put global verifier_verify_adb_installs 0; settings put global package_verifier_enable 0',30)
 status['control_install_transport']='no_streaming'
 install_and_verify('control',['install','--no-streaming','-r',str(R/'ci/control.apk')],'com.arena.installcontrol',1,90)
 status.update(state='control_installed',control_installed=True);save()
 result=shell('am start -W -n com.arena.installcontrol/android.app.Activity',60)
 assert 'Status: ok' in result,'Control start did not report Status ok'
 time.sleep(10);assert shell('pidof com.arena.installcontrol'), 'Control process did not survive'
 assert shell('pidof system_server')==status['system_server_pid_before'],'System restarted during control'
 screen('control.png');status.update(state='control_passed',control_launched=True);save()
 shell('am force-stop com.arena.installcontrol')
 if 'arm64-v8a' not in status['supported_abis']:raise RuntimeError('System image lacks advertised ARM64 native translation')
 package_dir=R/'downloaded-game';apks=[]
 archive=next(package_dir.glob('*.xapk'))
 with zipfile.ZipFile(archive) as z:
  for name in ['com.Ovilex.BusSimulator2023.apk','config.arm64_v8a.apk','UnityDataAssetPack.apk']:
   z.extract(name,package_dir);apks.append(str(package_dir/name))
 if os.environ.get('TEST_STOCK_CONTROL','').lower()=='true':
  assert not os.environ.get('TEST_BASE_OVERRIDE_ASSET') and not os.environ.get('TEST_CONFIG_OVERRIDE_ASSET'),'Stock control and modified overrides are mutually exclusive'
  manifest=json.loads((package_dir/'stock-original-manifest.json').read_text())
  original_asset=package_dir/'stock-UnityDataAssetPack.apk'
  with zipfile.ZipFile(package_dir/'stock-original-asset-layout.zip') as layout_zip, (package_dir/'UnityDataAssetPack.apk').open('rb') as source, original_asset.open('wb') as out:
   layout=json.loads(layout_zip.read('layout.json'))
   for part in layout['parts']:
    assert out.tell()==part['offset']
    if part['source']=='inline':out.write(layout_zip.read(part['path']))
    else:
     source.seek(part['local_offset']);left=part['size']
     while left:
      data=source.read(min(left,4*1024*1024));assert data;out.write(data);left-=len(data)
   assert out.tell()==layout['size']
  shutil.copyfile(package_dir/'stock-original-base.apk',package_dir/'com.Ovilex.BusSimulator2023.apk')
  shutil.copyfile(package_dir/'stock-original-config.apk',package_dir/'config.arm64_v8a.apk')
  original_asset.replace(package_dir/'UnityDataAssetPack.apk')
  status['variant']='cryptographically_verified_unmodified_original_control'
  status['installed_component_sha256']={}
  for name,expected in manifest['component_sha256'].items():
   with (package_dir/name).open('rb') as f:actual=hashlib.file_digest(f,'sha256').hexdigest()
   assert actual==expected,'Original component hash mismatch: '+name
   status['installed_component_sha256'][name]=actual
 candidate=package_dir/'candidate-base.apk'
 if os.environ.get('TEST_BASE_OVERRIDE_ASSET'):
  assert candidate.is_file(),'Requested candidate override was not downloaded'
  status['base_override_asset']=os.environ['TEST_BASE_OVERRIDE_ASSET']
  status['base_override_sha256']=hashlib.sha256(candidate.read_bytes()).hexdigest()
  shutil.copyfile(candidate,package_dir/'com.Ovilex.BusSimulator2023.apk')
 config_candidate=package_dir/'candidate-config.apk'
 if os.environ.get('TEST_CONFIG_OVERRIDE_ASSET'):
  assert config_candidate.is_file(),'Requested candidate config override was not downloaded'
  status['config_override_asset']=os.environ['TEST_CONFIG_OVERRIDE_ASSET']
  status['config_override_sha256']=hashlib.sha256(config_candidate.read_bytes()).hexdigest()
  shutil.copyfile(config_candidate,package_dir/'config.arm64_v8a.apk')
 if os.environ.get('TEST_RESIGN_KEYSTORE_ASSET'):
  keystore=package_dir/'test-signing.jks';assert keystore.is_file(),'Requested test keystore was not downloaded'
  status['resign_keystore_asset']=os.environ['TEST_RESIGN_KEYSTORE_ASSET'];save();resign_test_apks(apks,keystore)
 status['state']='installing_game';status['game_install_transport']='no_streaming';save()
 install_and_verify('game',['install-multiple','--no-streaming','-r','-t','--abi','arm64-v8a',*apks],PKG,3,420)
 status.update(state='game_installed',game_installed=True);save()
 adb(['logcat','-c'])
 shell('setprop debug.ld.app.com.Ovilex.BusSimulator2023 dlopen,dlsym,dlerror',30,False)
 status.update(state='launching_game',game_launch_attempted=True);save()
 got_monitor=None
 if os.environ.get('TEST_DUMP_VM','').lower()=='true':
  got_monitor=threading.Thread(target=dump_il2cpp_got_early,daemon=True);got_monitor.start()
 launch=shell('am start -W -n '+ACT,120,False)
 (D/'game-launch.txt').write_text(launch);status['launch_command_output']=launch
 if got_monitor:
  got_monitor.join(8)
  status['il2cpp_got_monitor_finished']=not got_monitor.is_alive();save()
 for elapsed in [15,45,120]:
  time.sleep(elapsed-(0 if elapsed==15 else 15 if elapsed==45 else 45))
  pid=shell('pidof '+PKG,30,False)
  status['app_pid_at_'+str(elapsed)+'s']=pid;save()
  try:screen('game-'+str(elapsed)+'s.png')
  except Exception as e:print('SCREENSHOT_FAILED',str(e),flush=True)
  if not pid:break
 status['system_server_pid_after']=shell('pidof system_server',30,False)
 status['foreground_activity']=shell("dumpsys activity activities | grep -E 'mResumedActivity|topResumedActivity'",30,False)
 crashes=adb(['logcat','-b','crash','-d'],30,False);(D/'crash-logcat.txt').write_text(crashes)
 game_crashed=PKG in crashes
 status['game_fatal_crash_seen']=game_crashed
 status['app_survived_120s']=bool(status.get('app_pid_at_120s'))
 status['foreground_is_game']=PKG in status['foreground_activity']
 status['runtime_start_verified']=bool(status['app_survived_120s'] and status['foreground_is_game'] and not game_crashed and 'Status: ok' in launch)
 status['state']='runtime_checked'
except Exception as e:
 status.update(state='failed',error=type(e).__name__+': '+str(e));traceback.print_exc()
finally:
 for name,args in [('final-logcat.txt',['logcat','-b','all','-d']),('kernel.txt',['shell','dmesg']),('processes.txt',['shell','ps -A'])]:
  try:(D/name).write_text(adb(args,30,False))
  except Exception as e:(D/name).write_text(str(e))
 try:adb(['pull','/data/tombstones',str(D/'tombstones')],60,False)
 except Exception as e:print('TOMBSTONE_CAPTURE_FAILED',str(e),flush=True)
 save()
 if log:log.terminate()
 print('FINAL_STATUS',json.dumps(status),flush=True)
 if not status.get('runtime_start_verified'):raise SystemExit(1)
