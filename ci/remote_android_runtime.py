import json,os,subprocess,time,traceback,zipfile
from pathlib import Path
R=Path(os.environ.get('GITHUB_WORKSPACE','.'));D=R/'runtime-results';D.mkdir(exist_ok=True)
A=os.environ.get('ANDROID_HOME','/usr/local/lib/android/sdk')+'/platform-tools/adb'
PKG='com.Ovilex.BusSimulator2023';ACT=PKG+'/com.google.firebase.MessagingUnityPlayerActivity'
status={'release_tag':os.environ['TEST_RELEASE_TAG'],'environment':'GitHub Actions Linux / KVM','control_installed':False,'control_launched':False,'game_installed':False,'game_launch_attempted':False,'gameplay_verified':False,'state':'waiting_for_android'}
def save(): (D/'status.json').write_text(json.dumps(status,indent=2))
def adb(args,timeout=30,check=True):
 print(time.strftime('%H:%M:%S'),'ADB',args,flush=True)
 r=subprocess.run([A,'-s','emulator-5554',*args],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=timeout)
 print(r.stdout,flush=True)
 if check and r.returncode:raise RuntimeError(f'ADB exit {r.returncode}: {r.stdout}')
 return r.stdout.strip()
def shell(cmd,timeout=30,check=True):return adb(['shell',cmd],timeout,check)
def screen(name):
 with (D/name).open('wb') as f:subprocess.run([A,'-s','emulator-5554','exec-out','screencap','-p'],stdout=f,timeout=30,check=True)
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
 log=subprocess.Popen([A,'-s','emulator-5554','logcat','-b','all','-v','threadtime'],stdout=log_file,stderr=subprocess.STDOUT)
 status['system_server_pid_before']=shell('pidof system_server')
 status['supported_abis']=shell('getprop ro.product.cpu.abilist')
 status['native_bridge']=shell('getprop ro.dalvik.vm.native.bridge')
 status['android_sdk']=shell('getprop ro.build.version.sdk')
 shell('settings put global verifier_verify_adb_installs 0; settings put global package_verifier_enable 0',30)
 adb(['install','-r',str(R/'ci/control.apk')],90)
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
 status['state']='installing_game';save()
 result=adb(['install-multiple','-r','-t','--abi','arm64-v8a',*apks],300)
 assert 'Success' in result,'No game install Success'
 status.update(state='game_installed',game_installed=True);save()
 adb(['logcat','-c'])
 shell('setprop debug.ld.app.com.Ovilex.BusSimulator2023 dlopen,dlsym,dlerror',30,False)
 status.update(state='launching_game',game_launch_attempted=True);save()
 launch=shell('am start -W -n '+ACT,120,False)
 (D/'game-launch.txt').write_text(launch);status['launch_command_output']=launch
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
