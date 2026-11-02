#!/usr/bin/env bash
# Native ARM64 Android Pie stock control on an x86_64 host without KVM.
# Uses the documented android-arm-tcg boot chain. Only emulator/guest boot and
# TCG-timeout components are patched; every installed game APK stays original.
set -euo pipefail
export PATH="/usr/local/sbin:/usr/sbin:/sbin:$PATH"
R=$(cd "$(dirname "$0")/.." && pwd)
C=/home/user/.cache/android-arm27-stock
SDK=$C/sdk
REPO=$C/android-arm-tcg
BUILD=$C/tcg-build
IMG=$SDK/system-images/android-28/google_apis/arm64-v8a
EMU_DIR=$C/emulator-16489710/emulator
QEMU=$EMU_DIR/qemu/linux-x86_64/qemu-system-aarch64-headless
ADB=$SDK/platform-tools/adb
PKGDIR=$C/original-xapk
RESULTS=$R/runtime-results
LOGD=$R/reverse/logs
mkdir -p "$BUILD" "$PKGDIR" "$RESULTS" "$LOGD"
cd "$R"

echo "=== [1/8] Dependencies and API-28 build tools $(date -Is) ==="
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq openjdk-21-jdk-headless gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu cpio qemu-utils e2fsprogs libgl1 libgl1-mesa-dri libglx-mesa0 > "$LOGD/arm28-apt.log" 2>&1
SDKM="$SDK/cmdline-tools/latest/bin/sdkmanager"
if [ ! -f "$SDK/platforms/android-28/android.jar" ] || [ ! -f "$SDK/build-tools/28.0.3/d8" ]; then
  "$SDKM" --sdk_root="$SDK" 'build-tools;28.0.3' 'platforms;android-28' > "$LOGD/arm28-sdk-tools.log" 2>&1
fi
for f in "$IMG/system.img" "$IMG/vendor.img" "$IMG/kernel-ranchu" "$IMG/ramdisk.img" "$QEMU" "$ADB" "$C/bus-evo-1.27.42.xapk"; do
  [ -f "$f" ] || { echo "Missing required input: $f" >&2; exit 10; }
done
if [ ! -d "$REPO/.git" ]; then git clone --depth 1 https://github.com/lhns/android-arm-tcg.git "$REPO"; fi

export SDK_ROOT="$SDK" BUILD_DIR="$BUILD" IMG="$IMG" EMU_DIR="$EMU_DIR" QEMU="$QEMU"
export ADB_BIN="$ADB" SERIAL=emulator-5554 ANDROID_SDK_ROOT="$SDK" ANDROID_I_WANT_MY_TCG=yes
export ADB_TIMEOUT=150 CORES=1 MEM=1024

echo "=== [2/8] Verified boot-image patches $(date -Is) ==="
for f in "$QEMU" "$IMG/kernel-ranchu" "$IMG/vendor.img" "$EMU_DIR/lib64/libgfxstream_backend.so"; do
  [ -f "$f.stock" ] || cp "$f" "$f.stock"
done
"$REPO/scripts/10-patch-image.sh" 2>&1 | tee "$LOGD/arm28-patch-image.log"
sudo -E "$REPO/scripts/20-build-ramdisk.sh" 2>&1 | tee "$LOGD/arm28-build-ramdisk.log"

echo "=== [3/8] Signature-located TCG framework patches $(date -Is) ==="
mkdir -p "$BUILD/oat"
extract_oat() {
  local guest1=$1 guest2=$2 out=$3 loop
  rm -f "$out"
  # Pinned API-28 GPT: one system partition, first LBA 2048, 5242880 sectors.
  loop=$(sudo losetup --find --show --read-only --offset $((2048*512)) --sizelimit $((5242880*512)) "$IMG/system.img")
  sudo debugfs -R "dump $guest1 $out" "$loop" >/dev/null 2>&1 || true
  if [ ! -s "$out" ]; then sudo debugfs -R "dump $guest2 $out" "$loop" >/dev/null 2>&1 || true; fi
  sudo losetup -d "$loop" || true
  [ -s "$out" ] || { echo "Cannot extract $guest1/$guest2" >&2; exit 11; }
  sudo chown "$(id -u):$(id -g)" "$out"
}
extract_oat /framework/oat/arm64/services.odex /system/framework/oat/arm64/services.odex "$BUILD/oat/services.odex"
extract_oat /framework/arm64/boot-core-libart.oat /system/framework/arm64/boot-core-libart.oat "$BUILD/oat/boot-core-libart.oat"
python3 - "$BUILD/oat/services.odex" "$BUILD/oat/boot-core-libart.oat" "$LOGD/arm28-oat-patches.json" <<'PY'
import json,sys
from pathlib import Path
services=Path(sys.argv[1]);libart=Path(sys.argv[2]);report=Path(sys.argv[3])
s=bytearray(services.read_bytes());l=bytearray(libart.read_bytes());records=[]
def unique_patch(buf,name,context,at,replacement,required=True):
    needle=bytes.fromhex(context);repl=bytes.fromhex(replacement)
    positions=[];start=0
    while True:
        p=buf.find(needle,start)
        if p<0:break
        positions.append(p);start=p+1
    rec={'name':name,'matches':len(positions),'required':required}
    if len(positions)==1:
        p=positions[0]+at;buf[p:p+len(repl)]=repl
        rec.update(applied=True,file_offset=hex(p),before=needle[at:at+len(repl)].hex(),after=repl.hex())
    else:
        rec['applied']=False
        if required:raise SystemExit('Required signature is not unique: '+json.dumps(rec))
    records.append(rec)
# Group B: avoid a second whole-APK SHA pass and use the long process-attach timeout.
unique_patch(s,'skipVerify','00180051e10319aae20315aa201a00d0008845f9',8,'22008052')
unique_patch(s,'PROC_START short-timeout immediate','03e284d20300001403f089d2',0,'e3ff9fd2')
unique_patch(s,'PROC_START long branch','d4ba3ab521d340b977000035',8,'03000014')
# Group A finalizer timeout (recommended; WdCtl remains the watchdog controller).
unique_patch(l,'Finalizer 10s to 1h','02809cd26281aaf24200c0f2',0,'020094d20217a6f2c268c0f2',False)
def known_offset(buf,name,offset,before,after):
    old=bytes.fromhex(before);new=bytes.fromhex(after);actual=bytes(buf[offset:offset+len(old)])
    rec={'name':name,'file_offset':hex(offset),'before':before,'after':after}
    if actual==old:
        buf[offset:offset+len(new)]=new;rec['applied']=True
    elif actual==new:
        rec['applied']='already'
    else:
        raise SystemExit('OAT method-entry mismatch: '+json.dumps(rec)+' actual='+actual.hex())
    records.append(rec)
# Entries recovered with the guest's own oatdump; file offset = code_offset + 0x1000.
known_offset(s,'Watchdog.run return',0x007bd950+0x1000,'f00b40d11f0240b9','c0035fd61f2003d5')
known_offset(s,'GnssLocationProvider.isSupported return false',0x01313d00+0x1000,'f00b40d11f0240b9','00008052c0035fd6')
services.write_bytes(s);libart.write_bytes(l)
report.write_text(json.dumps(records,indent=2))
print(json.dumps(records,indent=2))
PY

echo "=== [4/8] Launch native ARM64 QEMU $(date -Is) ==="
sync
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
free -h
"$ADB" kill-server >/dev/null 2>&1 || true
"$ADB" start-server >/dev/null 2>&1
rm -rf "$RESULTS"
mkdir -p "$RESULTS"
"$REPO/scripts/30-launch.sh" 2>&1 | tee "$LOGD/arm28-launch.log"
QPID=$(cat "$BUILD/qemu.pid")
cleanup() {
  set +e
  kill "$QPID" >/dev/null 2>&1
  sleep 2
  kill -9 "$QPID" >/dev/null 2>&1
}
trap cleanup EXIT
sleep 5
kill -0 "$QPID" || { tail -200 "$BUILD/emu.log"; exit 20; }

echo "=== [5/8] Guest bring-up to systemReady $(date -Is) ==="
set +e
timeout 2500 "$REPO/scripts/40-bringup.sh" 2>&1 | tee "$RESULTS/bringup-console.txt"
BRC=${PIPESTATUS[0]}
set -e
if [ "$BRC" -ne 0 ]; then
  echo "Bring-up failed rc=$BRC"
  timeout 30 "$ADB" -s emulator-5554 shell 'cat /data/local/tmp/bringup.log; getprop; ps -A' > "$RESULTS/bringup-failure-device.txt" 2>&1 || true
  cp "$BUILD/emu.log" "$RESULTS/emulator.log" || true
  tail -200 "$BUILD/emu.log"
  exit "$BRC"
fi
"$ADB" -s emulator-5554 shell 'getprop ro.product.cpu.abilist; getprop ro.dalvik.vm.native.bridge; getprop ro.build.version.sdk; uname -a; service check package; service check media.audio_policy; getprop sys.boot_completed' | tee "$RESULTS/device-identity.txt"
"$ADB" -s emulator-5554 shell 'setprop pm.dexopt.install extract' >/dev/null 2>&1 || true

echo "=== [6/8] Original APK staging and identity $(date -Is) ==="
ln -sfn "$C/bus-evo-1.27.42.xapk" "$PKGDIR/bus-evo-1.27.42.xapk"
echo 'ae537b3874e50f0b8953c29c85f1bd46e8cab2be1c6b66c950225a675f652bfb  '"$C/bus-evo-1.27.42.xapk" | sha256sum -c - | tee "$RESULTS/original-xapk-sha256.txt"

echo "=== [7/8] Original stock install and launch $(date -Is) ==="
export ANDROID_HOME="$SDK" ANDROID_SERIAL=emulator-5554
export TEST_RELEASE_TAG=local-arm28-native-stock
export TEST_ENVIRONMENT='Local x86_64 host / native ARM64 Android 9 API 28 full-system TCG; no Berberis; TCG boot/timeout workarounds; original game APKs'
export TEST_PACKAGE_DIR="$PKGDIR" ANDROID_SKIP_ADB_ROOT=true
export ANDROID_DEVICE_TIMEOUT=180 ANDROID_BOOT_TIMEOUT=300 ANDROID_INSTALL_TIMEOUT=1800 ANDROID_LAUNCH_TIMEOUT=300
export ANDROID_CONTROL_INSTALL_TIMEOUT=600 ANDROID_CONTROL_LAUNCH_TIMEOUT=300 ANDROID_SCREENSHOT_TIMEOUT=150
export ANDROID_PACKAGE_READY=true ANDROID_READY_TIMEOUT=150 ANDROID_MIN_ADB_TIMEOUT=120
export ANDROID_ALLOW_INSTALL_RESTART=true ANDROID_PACKAGE_REGISTER_TIMEOUT=900 ANDROID_WAKE_BEFORE_GAME=true
unset TEST_STOCK_CONTROL TEST_BASE_OVERRIDE_ASSET TEST_CONFIG_OVERRIDE_ASSET TEST_RESIGN_KEYSTORE_ASSET TEST_DUMP_VM
set +e
python3 ci/remote_android_runtime.py 2>&1 | tee "$RESULTS/test-console.txt"
HRC=${PIPESTATUS[0]}
set -e

echo "=== [8/8] Evidence $(date -Is) ==="
cp -f "$BUILD/emu.log" "$RESULTS/emulator.log" || true
cp -f "$BUILD/emu.log" "$LOGD/arm28-stock-emulator.log" || true
printf 'BRINGUP_EXIT=%s\nHARNESS_EXIT=%s\n' "$BRC" "$HRC" | tee "$RESULTS/orchestrator-status.txt"
cat "$RESULTS/status.json" || true
exit "$HRC"
