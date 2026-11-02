#!/usr/bin/env bash
# Rebuild the ephemeral local toolchain, boot a native ARM64 Android 8.1 guest
# under TCG, and run the existing install/launch harness against the verified
# original XAPK.  All mutable downloads remain outside the persisted workspace.
set -euo pipefail
R=$(cd "$(dirname "$0")/.." && pwd)
C=/home/user/.cache/android-arm27-stock
SDK=$C/sdk
EMU_ZIP=$C/emulator-linux_x64-16489710.zip
EMU_HOME=$C/emulator-16489710/emulator
AVD_HOME=$C/avd
AVD=BusStockARM27
XAPK=$C/bus-evo-1.27.42.xapk
LOGD=$R/reverse/logs
RESULTS=$R/runtime-results
mkdir -p "$C" "$SDK" "$AVD_HOME" "$LOGD" "$RESULTS" "$R/downloaded-game"
cd "$R"

echo "=== [1/7] Host dependencies $(date -Is) ==="
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq openjdk-21-jre-headless libpulse0 qemu-utils e2fsprogs curl unzip > "$LOGD/arm27-apt.log" 2>&1
free -h
if ! sudo swapon --show=NAME --noheadings | grep -q .; then
  echo 'No active swap; creating a 2 GiB ephemeral swap file.'
  sudo fallocate -l 2G "$C/swapfile"
  sudo chmod 600 "$C/swapfile"
  sudo mkswap "$C/swapfile"
  sudo swapon "$C/swapfile"
fi

echo "=== [2/7] SDK and pinned TCG-capable emulator $(date -Is) ==="
if [ ! -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
  curl -fL --retry 3 -o "$C/cmdline-tools.zip" https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
  rm -rf "$C/cmdline-unpack" "$SDK/cmdline-tools/latest"
  mkdir -p "$C/cmdline-unpack" "$SDK/cmdline-tools/latest"
  unzip -q "$C/cmdline-tools.zip" -d "$C/cmdline-unpack"
  mv "$C/cmdline-unpack/cmdline-tools"/* "$SDK/cmdline-tools/latest/"
fi
SDKM="$SDK/cmdline-tools/latest/bin/sdkmanager"
yes | "$SDKM" --sdk_root="$SDK" --licenses > "$LOGD/arm27-licenses.log" 2>&1 || true
if [ ! -x "$SDK/platform-tools/adb" ]; then
  "$SDKM" --sdk_root="$SDK" platform-tools > "$LOGD/arm27-sdk-platform.log" 2>&1
fi
IMG_REL=''
if [ ! -f "$SDK/system-images/android-27/google_apis/arm64-v8a/system.img" ] && [ ! -f "$SDK/system-images/android-27/default/arm64-v8a/system.img" ]; then
  set +e
  "$SDKM" --sdk_root="$SDK" 'system-images;android-27;google_apis;arm64-v8a' > "$LOGD/arm27-sdk-image.log" 2>&1
  rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    echo 'Google APIs API-27 ARM64 image unavailable; trying default API-27 ARM64.'
    "$SDKM" --sdk_root="$SDK" 'system-images;android-27;default;arm64-v8a' >> "$LOGD/arm27-sdk-image.log" 2>&1
  fi
fi
if [ -f "$SDK/system-images/android-27/google_apis/arm64-v8a/system.img" ]; then
  IMG_REL='system-images/android-27/google_apis/arm64-v8a/'
  TAG_ID=google_apis
elif [ -f "$SDK/system-images/android-27/default/arm64-v8a/system.img" ]; then
  IMG_REL='system-images/android-27/default/arm64-v8a/'
  TAG_ID=default
else
  echo 'No API-27 ARM64 system image installed.' >&2
  tail -100 "$LOGD/arm27-sdk-image.log" >&2 || true
  exit 20
fi
if [ ! -x "$EMU_HOME/emulator" ]; then
  curl -fL --retry 3 -o "$EMU_ZIP" https://dl.google.com/android/repository/emulator-linux_x64-16489710.zip
  echo 'a0da0fa20903a69ae52ab501f30fc5c768dcce31434cd2f55d52addc1a2c0495  '"$EMU_ZIP" | sha256sum -c -
  rm -rf "$C/emulator-16489710"
  mkdir -p "$C/emulator-16489710"
  unzip -q "$EMU_ZIP" -d "$C/emulator-16489710"
fi

echo "=== [3/7] Verified original XAPK $(date -Is) ==="
if [ ! -f "$XAPK" ]; then
  curl -fL --retry 4 --retry-delay 2 -o "$XAPK" 'https://d.apkpure.net/b/XAPK/com.Ovilex.BusSimulator2023?version=latest'
fi
echo 'ae537b3874e50f0b8953c29c85f1bd46e8cab2be1c6b66c950225a675f652bfb  '"$XAPK" | sha256sum -c -
python3 - "$XAPK" <<'PY'
import sys,zipfile
p=sys.argv[1]
with zipfile.ZipFile(p) as z:
    expected={'com.Ovilex.BusSimulator2023.apk','config.arm64_v8a.apk','UnityDataAssetPack.apk','manifest.json'}
    assert expected <= set(z.namelist()), z.namelist()
    print('XAPK entries:', [(i.filename,i.file_size) for i in z.infolist()])
PY
ln -sfn "$XAPK" "$R/downloaded-game/bus-evo-1.27.42.xapk"
rm -f "$R/downloaded-game/com.Ovilex.BusSimulator2023.apk" "$R/downloaded-game/config.arm64_v8a.apk" "$R/downloaded-game/UnityDataAssetPack.apk"

echo "=== [4/7] AVD configuration $(date -Is) ==="
AVD_DIR=$AVD_HOME/$AVD.avd
mkdir -p "$AVD_DIR"
cat > "$AVD_HOME/$AVD.ini" <<EOF
avd.ini.encoding=UTF-8
path=$AVD_DIR
path.rel=avd/$AVD.avd
target=android-27
EOF
cat > "$AVD_DIR/config.ini" <<EOF
AvdId=$AVD
PlayStore.enabled=false
abi.type=arm64-v8a
avd.ini.displayname=Bus Stock ARM27
avd.ini.encoding=UTF-8
disk.dataPartition.size=6442450944
hw.accelerometer=yes
hw.audioInput=no
hw.audioOutput=no
hw.battery=yes
hw.camera.back=none
hw.camera.front=none
hw.cpu.arch=arm64
hw.cpu.ncore=1
hw.dPad=no
hw.device.name=pixel_2
hw.gps=yes
hw.gpu.enabled=yes
hw.gpu.mode=swiftshader_indirect
hw.initialOrientation=Portrait
hw.keyboard=yes
hw.lcd.density=240
hw.lcd.height=800
hw.lcd.width=480
hw.mainKeys=no
hw.ramSize=1536
hw.sdCard=no
hw.sensors.orientation=yes
hw.sensors.proximity=yes
hw.trackBall=no
image.sysdir.1=$IMG_REL
showDeviceFrame=no
skin.dynamic=yes
tag.display=Google APIs
tag.id=$TAG_ID
target=android-27
EOF

echo "=== [5/7] Native ARM64 TCG boot $(date -Is) ==="
export ANDROID_HOME="$SDK" ANDROID_SDK_ROOT="$SDK" ANDROID_AVD_HOME="$AVD_HOME"
export ANDROID_USER_HOME="$C/user" ANDROID_I_WANT_MY_TCG=yes
ADB="$SDK/platform-tools/adb"
"$ADB" start-server
"$ADB" kill-server 2>/dev/null || true
"$ADB" start-server
EMULATOR_LOG=$RESULTS/emulator.log
: > "$EMULATOR_LOG"
"$EMU_HOME/emulator" -avd "$AVD" -no-window -no-audio -no-snapshot -no-boot-anim \
  -accel off -memory 1536 -cores 1 -gpu swiftshader_indirect -feature -Vulkan \
  -camera-back none -camera-front none -no-metrics -show-kernel > "$EMULATOR_LOG" 2>&1 &
EPID=$!
cleanup() {
  set +e
  "$ADB" -s emulator-5554 emu kill >/dev/null 2>&1
  kill "$EPID" >/dev/null 2>&1
  wait "$EPID" >/dev/null 2>&1
}
trap cleanup EXIT
sleep 5
if ! kill -0 "$EPID" 2>/dev/null; then
  echo 'Emulator exited during startup.'
  tail -160 "$EMULATOR_LOG"
  exit 30
fi
BOOT_DEADLINE=$((SECONDS+1500))
READY=0
LAST_REPORT=-60
while (( SECONDS < BOOT_DEADLINE )); do
  if ! kill -0 "$EPID" 2>/dev/null; then
    echo 'Emulator exited before Android became ready.'
    tail -200 "$EMULATOR_LOG"
    exit 31
  fi
  PROBE=$(timeout 8 "$ADB" -s emulator-5554 shell 'getprop sys.boot_completed; getprop ro.product.cpu.abi; getprop ro.build.version.sdk' 2>/dev/null || true)
  if [[ "$PROBE" == 1$'\n'* ]]; then READY=1; break; fi
  if (( SECONDS-LAST_REPORT >= 60 )); then
    echo "BOOT_PROBE elapsed=${SECONDS}s probe=$(echo "$PROBE" | tr '\n' ' ') qemu_log=$(tail -1 "$EMULATOR_LOG" | cut -c1-180)"
    LAST_REPORT=$SECONDS
  fi
  sleep 5
done
if [ "$READY" -ne 1 ]; then
  echo 'Android boot deadline reached.'
  timeout 15 "$ADB" -s emulator-5554 shell 'getprop; ps -A; dmesg' > "$RESULTS/boot-timeout-device.txt" 2>&1 || true
  tail -240 "$EMULATOR_LOG"
  exit 32
fi
echo "Android reports boot completed after ${SECONDS}s; collecting identity."
"$ADB" -s emulator-5554 shell 'getprop ro.product.cpu.abilist; getprop ro.dalvik.vm.native.bridge; getprop ro.build.version.sdk; uname -a' | tee "$RESULTS/device-identity.txt"

echo "=== [6/7] Original stock install and launch $(date -Is) ==="
export TEST_RELEASE_TAG=local-arm27-stock
export TEST_ENVIRONMENT='Local x86_64 host / native ARM64 Android 8.1 API 27 full-system TCG; no Berberis'
export ANDROID_SERIAL=emulator-5554
export ANDROID_DEVICE_TIMEOUT=180 ANDROID_BOOT_TIMEOUT=300
export ANDROID_INSTALL_TIMEOUT=1200 ANDROID_LAUNCH_TIMEOUT=300
unset TEST_STOCK_CONTROL TEST_BASE_OVERRIDE_ASSET TEST_CONFIG_OVERRIDE_ASSET TEST_RESIGN_KEYSTORE_ASSET TEST_DUMP_VM
set +e
python3 ci/remote_android_runtime.py 2>&1 | tee "$RESULTS/test-console.txt"
HRC=${PIPESTATUS[0]}
set -e

echo "=== [7/7] Preserve evidence $(date -Is) ==="
python3 - "$XAPK" "$RESULTS/original-xapk-sha256.txt" <<'PY'
import hashlib,sys
p,out=sys.argv[1:]
h=hashlib.sha256()
with open(p,'rb') as f:
    for b in iter(lambda:f.read(8*1024*1024),b''):h.update(b)
open(out,'w').write(h.hexdigest()+'  '+p+'\n')
PY
cp -f "$EMULATOR_LOG" "$LOGD/arm27-stock-emulator.log" || true
printf 'HARNESS_EXIT=%s\n' "$HRC" | tee "$RESULTS/orchestrator-status.txt"
cat "$RESULTS/status.json" || true
exit "$HRC"
