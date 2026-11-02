#!/usr/bin/env bash
# Unmodified ARM64 game on the mature x86_64 TCG system-image path.
# This is a libndk_translation comparison, not a native-ARM64 execution result.
set -euo pipefail
export PATH="/usr/local/sbin:/usr/sbin:/sbin:$PATH"
R=$(cd "$(dirname "$0")/.." && pwd)
C=/home/user/.cache/android-arm27-stock
SDK=$C/sdk
IMG_REL=system-images/android-35/google_apis/x86_64
IMG=$SDK/$IMG_REL
EMU=$SDK/emulator/emulator
ADB=$SDK/platform-tools/adb
SDKM=$SDK/cmdline-tools/latest/bin/sdkmanager
AVD_HOME=$C/avd-x86-stock
AVD=$AVD_HOME/stock-x86.avd
RESULTS=$R/runtime-results
LOGD=$R/reverse/logs
PKGDIR=$C/original-xapk
XAPK=$C/bus-evo-1.27.42.xapk
mkdir -p "$C/tmp" "$AVD_HOME" "$PKGDIR" "$LOGD"
export TMPDIR=$C/tmp ANDROID_SDK_ROOT=$SDK ANDROID_HOME=$SDK
export ANDROID_AVD_HOME=$AVD_HOME ANDROID_EMULATOR_HOME=$C/emulator-home-x86
export ANDROID_SERIAL=emulator-5554
cd "$R"

echo "=== [0/6] Restore ephemeral tools and verified original $(date -Is) ==="
if [ ! -x /usr/lib/jvm/java-21-openjdk-amd64/bin/java ]; then
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq
  sudo apt-get install -y -qq openjdk-21-jdk-headless libgl1 libgl1-mesa-dri libglx-mesa0 > "$LOGD/x86-stock-apt.log" 2>&1
fi
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
if [ ! -x "$SDKM" ]; then
  rm -rf "$C/cmdline-unpack" "$SDK/cmdline-tools"
  mkdir -p "$C/cmdline-unpack" "$SDK/cmdline-tools"
  curl -fL --retry 5 --retry-all-errors --connect-timeout 30 \
    'https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip' \
    -o "$C/commandline-tools.zip"
  unzip -q "$C/commandline-tools.zip" -d "$C/cmdline-unpack"
  mv "$C/cmdline-unpack/cmdline-tools" "$SDK/cmdline-tools/latest"
  rm -f "$C/commandline-tools.zip"
fi
mkdir -p "$SDK/licenses"
printf '%s\n' '8933bad161af4178b1185d1a37fbf41ea5269c55' \
  'd56f5187479451eabf01fb78af6dfcb131a6481e' \
  '24333f8a63b6825ea9c5514f83c2829b004d1fee' > "$SDK/licenses/android-sdk-license"
if [ ! -x "$ADB" ] || [ ! -x "$EMU" ]; then
  "$SDKM" --sdk_root="$SDK" platform-tools emulator </dev/null > "$LOGD/x86-stock-sdk-tools.log" 2>&1
fi
if [ ! -f "$XAPK" ]; then
  curl -fL --retry 5 --retry-all-errors --connect-timeout 30 \
    'https://d.apkpure.net/b/XAPK/com.Ovilex.BusSimulator2023?version=latest' \
    -o "$XAPK.part"
  echo 'ae537b3874e50f0b8953c29c85f1bd46e8cab2be1c6b66c950225a675f652bfb  '"$XAPK.part" | sha256sum -c -
  mv "$XAPK.part" "$XAPK"
fi

echo "=== [1/6] x86_64 API-35 system image $(date -Is) ==="
if [ ! -f "$IMG/system.img" ]; then
  # The API-27 ARM image is a known-failing template and is not used by any
  # active route. Reclaim it only when necessary for the x86_64 image download.
  avail=$(df -Pm "$C" | awk 'NR==2{print $4}')
  if [ "$avail" -lt 7000 ] && [ -d "$SDK/system-images/android-27/google_apis/arm64-v8a" ]; then
    rm -rf "$SDK/system-images/android-27/google_apis/arm64-v8a"
  fi
  "$SDKM" --sdk_root="$SDK" 'system-images;android-35;google_apis;x86_64' </dev/null > "$LOGD/x86-stock-sdk-install.log" 2>&1
fi
for f in "$IMG/system.img" "$EMU" "$ADB" "$XAPK" "$R/ci/control.apk"; do
  [ -f "$f" ] || { echo "Missing required input: $f" >&2; exit 10; }
done

echo "=== [2/6] AVD and emulator launch $(date -Is) ==="
python3 - "$SDK/emulator" "$LOGD/x86-hang-patch.json" <<'PYEOF'
import json,struct,shutil,sys
from pathlib import Path
root=Path(sys.argv[1]);report=Path(sys.argv[2]);records=[]
def patch_library(path):
    stock=path.with_suffix(path.suffix+'.stock')
    if not stock.exists():shutil.copy2(path,stock)
    data=bytearray(stock.read_bytes())
    h=struct.unpack_from('<16sHHIQQQIHHHHHH',data,0)
    assert h[0][:4]==b'\x7fELF' and h[0][4:6]==b'\x02\x01'
    phoff,shoff=h[5],h[6];phentsize,phnum=h[9],h[10];shentsize,shnum=h[11],h[12]
    sections=[struct.unpack_from('<IIQQQQIIQQ',data,shoff+i*shentsize) for i in range(shnum)]
    found=[]
    for sec in sections:
        if sec[1]!=11:continue
        strings=sections[sec[6]];strdata=data[strings[4]:strings[4]+strings[5]]
        for off in range(sec[4],sec[4]+sec[5],sec[9]):
            st=struct.unpack_from('<IBBHQQ',data,off)
            end=strdata.find(b'\0',st[0]);name=bytes(strdata[st[0]:end]).decode('utf-8','replace')
            if 'addWatchedLooper' not in name or not st[4] or not st[3]:continue
            value=st[4];fileoff=None
            for i in range(phnum):
                ph=struct.unpack_from('<IIQQQQQQ',data,phoff+i*phentsize)
                if ph[0]==1 and ph[3]<=value<ph[3]+ph[5]:
                    fileoff=ph[2]+value-ph[3];break
            assert fileoff is not None
            found.append((name,fileoff))
    if len(found)!=1:raise RuntimeError(f'{path}: expected one defined addWatchedLooper, got {found}')
    name,off=found[0];before=data[off:off+16].hex();data[off]=0xc3
    path.write_bytes(data)
    records.append({'library':str(path),'symbol':name,'file_offset':hex(off),'before':before,'after':data[off:off+16].hex(),'patch':'return before registering any watched looper'})
for rel in ['lib64/libandroid-emu-shared.so','lib64/libgfxstream_backend.so']:patch_library(root/rel)
report.write_text(json.dumps(records,indent=2));print(json.dumps(records,indent=2))
PYEOF
if [ "${REUSE_AVD:-false}" != "true" ]; then rm -rf "$AVD"; fi
mkdir -p "$AVD"
cat > "$AVD_HOME/stock-x86.ini" <<EOF
avd.ini.encoding=UTF-8
path=$AVD
path.rel=avd/stock-x86.avd
target=android-35
EOF
cat > "$AVD/config.ini" <<EOF
AvdId=stock-x86
PlayStore.enabled=false
abi.type=x86_64
avd.ini.displayname=Stock x86 TCG
avd.ini.encoding=UTF-8
disk.dataPartition.size=4096M
fastboot.forceColdBoot=yes
hw.accelerated=no
hw.audioInput=no
hw.audioOutput=no
hw.camera.back=none
hw.camera.front=none
hw.cpu.arch=x86_64
hw.cpu.ncore=2
hw.device.manufacturer=Google
hw.device.name=pixel_6
hw.gps=no
hw.gpu.enabled=yes
hw.gpu.mode=swiftshader_indirect
hw.keyboard=yes
hw.lcd.density=160
hw.lcd.height=800
hw.lcd.width=480
hw.ramSize=2560
hw.sensors.orientation=no
hw.sensors.proximity=no
image.sysdir.1=$IMG_REL/
runtime.network.latency=none
runtime.network.speed=full
showDeviceFrame=no
tag.display=Google APIs
tag.id=google_apis
vm.heapSize=256
EOF
mkdir -p "$ANDROID_EMULATOR_HOME"
if [ ! -f "$ANDROID_EMULATOR_HOME/adbkey" ]; then
  "$ADB" keygen "$ANDROID_EMULATOR_HOME/adbkey" >/dev/null 2>&1
fi
export ADB_VENDOR_KEYS="$ANDROID_EMULATOR_HOME/adbkey"
if ! swapon --show=NAME --noheadings | grep -Fxq "$C/arena-x86.swap"; then
  if [ ! -f "$C/arena-x86.swap" ]; then
    fallocate -l 4G "$C/arena-x86.swap"
    chmod 600 "$C/arena-x86.swap"
    sudo mkswap "$C/arena-x86.swap" >/dev/null
  fi
  sudo swapon "$C/arena-x86.swap"
fi
"$ADB" kill-server >/dev/null 2>&1 || true
"$ADB" start-server >/dev/null 2>&1
rm -rf "$RESULTS"
mkdir -p "$RESULTS"
sync
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches' || true
free -h
setsid "$EMU" -avd stock-x86 -no-window -no-audio -no-boot-anim \
  -no-snapshot -no-snapshot-save -no-metrics \
  -accel off -cores 2 -memory 2560 -gpu swiftshader_indirect \
  -camera-back none -camera-front none \
  -qemu -m 2560 \
  </dev/null > "$LOGD/x86-stock-emulator.log" 2>&1 &
EPID=$!
echo "$EPID" > "$RESULTS/emulator.pid"
cleanup() {
  set +e
  if [ -n "${GUARDIAN_PID:-}" ]; then kill "$GUARDIAN_PID" >/dev/null 2>&1; wait "$GUARDIAN_PID" >/dev/null 2>&1; fi
  kill -- "-$EPID" >/dev/null 2>&1
  sleep 2
  kill -9 -- "-$EPID" >/dev/null 2>&1
}
trap cleanup EXIT
sleep 12
if ! kill -0 "$EPID" 2>/dev/null; then
  tail -200 "$LOGD/x86-stock-emulator.log"
  exit 20
fi
timeout 1200 "$ADB" -s emulator-5554 wait-for-device
"$ADB" -s emulator-5554 root >/dev/null 2>&1 || true
timeout 600 "$ADB" -s emulator-5554 wait-for-device
# Restart the framework so early dexopt properties apply before boot. The
# original framework OAT remains untouched; a passive JDWP guardian below
# prevents Watchdog from killing slow TCG system_server generations.
"$ADB" -s emulator-5554 shell 'stop zygote' >/dev/null 2>&1 || true
# Apply these before the new framework reaches UpdatePackagesIfNeeded. Modern
# emulator -prop accepts only qemu.* keys, so an early zygote restart is used.
"$ADB" -s emulator-5554 shell 'setprop pm.dexopt.boot extract; setprop pm.dexopt.first-boot extract; setprop pm.dexopt.post-boot-update extract; setprop pm.dexopt.install extract; setprop pm.dexopt.bg-dexopt extract; setprop pm.dexopt.ab-ota extract; setprop pm.dexopt.inactive extract; setprop pm.dexopt.shared extract; setprop dalvik.vm.usejit false; getprop pm.dexopt.boot; getprop pm.dexopt.first-boot; getprop pm.dexopt.post-boot-update; getprop dalvik.vm.usejit; setprop ro.hw_timeout_multiplier 60; getprop ro.hw_timeout_multiplier; setprop sys.boot_completed 0; getprop sys.boot_completed; start zygote' | tee "$RESULTS/early-properties.txt"


"$ADB" -s emulator-5554 shell 'getprop ro.hw_timeout_multiplier' | tr -d '\r' > "$RESULTS/hw-timeout-multiplier.txt"
grep -qx '60' "$RESULTS/hw-timeout-multiplier.txt" || { echo 'ro.hw_timeout_multiplier did not stick; refusing an unchanged Watchdog run' >&2; exit 31; }

echo "=== [3/6] Original package identity $(date -Is) ==="
ln -sfn "$XAPK" "$PKGDIR/bus-evo-1.27.42.xapk"
echo 'ae537b3874e50f0b8953c29c85f1bd46e8cab2be1c6b66c950225a675f652bfb  '"$XAPK" | sha256sum -c - | tee "$RESULTS/original-xapk-sha256.txt"

echo "=== [4/6] Original install and launch $(date -Is) ==="
export TEST_RELEASE_TAG=local-x86-api35-stock
export TEST_ENVIRONMENT='Local x86_64 Android 15 API 35 full-system TCG without KVM; ARM64 app through the image native bridge; original unmodified game APKs'
export TEST_PACKAGE_DIR="$PKGDIR"
export ANDROID_DEVICE_TIMEOUT=240 ANDROID_BOOT_TIMEOUT=1200
export ANDROID_READY_TIMEOUT=90 ANDROID_MIN_ADB_TIMEOUT=45
export ANDROID_CONTROL_INSTALL_TIMEOUT=600 ANDROID_CONTROL_LAUNCH_TIMEOUT=180
export ANDROID_INSTALL_TIMEOUT=1800 ANDROID_LAUNCH_TIMEOUT=300
export ANDROID_SCREENSHOT_TIMEOUT=120 ANDROID_WAKE_BEFORE_GAME=true
export ANDROID_REUSE_CONTROL_INSTALL=true ANDROID_REUSE_GAME_INSTALL=true
export ANDROID_PRECONTROL_SETTLE_SECONDS=15
unset TEST_STOCK_CONTROL TEST_BASE_OVERRIDE_ASSET TEST_CONFIG_OVERRIDE_ASSET
unset TEST_RESIGN_KEYSTORE_ASSET TEST_DUMP_VM ANDROID_ALLOW_INSTALL_RESTART
unset ANDROID_PACKAGE_READY ANDROID_PACKAGE_REGISTER_TIMEOUT ANDROID_SKIP_ADB_ROOT
set +e
python3 ci/remote_android_runtime.py 2>&1 | tee "$RESULTS/test-console.txt"
HRC=${PIPESTATUS[0]}
set -e

echo "=== [5/6] Device and emulator evidence $(date -Is) ==="
timeout 60 "$ADB" -s emulator-5554 shell 'getprop ro.product.cpu.abilist; getprop ro.dalvik.vm.native.bridge; getprop ro.build.version.sdk; uname -a' > "$RESULTS/device-identity.txt" 2>&1 || true
cp -f "$LOGD/x86-stock-emulator.log" "$RESULTS/emulator.log" || true

echo "=== [6/6] Result $(date -Is) ==="
printf 'HARNESS_EXIT=%s\n' "$HRC" | tee "$RESULTS/orchestrator-status.txt"
cat "$RESULTS/status.json" || true
exit "$HRC"
