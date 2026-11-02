#!/usr/bin/env bash
set -Eeuo pipefail
mkdir -p runtime-results "$ANDROID_AVD_HOME"
cleanup() { adb emu kill >/dev/null 2>&1 || true; }
trap cleanup EXIT
# SDK is supplied read-only by the Actions host; the AVD and application live
# exclusively in this container. No host adb server or host network is used.
echo no | "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" create avd --force \
  --name BusDocker --package 'system-images;android-35;google_apis;x86_64'
cat >> "$ANDROID_AVD_HOME/BusDocker.avd/config.ini" <<'AVD'
hw.cpu.ncore=2
hw.ramSize=3072
hw.lcd.width=480
hw.lcd.height=800
hw.lcd.density=160
hw.gpu.enabled=yes
hw.gpu.mode=swangle
disk.dataPartition.size=6G
AVD
emulator -accel-check > runtime-results/acceleration.txt 2>&1
adb start-server
emulator -avd BusDocker -no-window -no-audio -no-snapshot -no-boot-anim \
  -accel on -memory 3072 -cores 2 -gpu swangle -feature -Vulkan \
  -camera-back none -camera-front none -no-metrics > runtime-results/emulator.log 2>&1 &
EMULATOR_PID=$!
# Fail immediately for a host/container error instead of waiting three minutes
# and incorrectly presenting it as an APK failure.
for attempt in $(seq 1 30); do
  if ! kill -0 "$EMULATOR_PID" 2>/dev/null; then
    cat runtime-results/emulator.log
    exit 20
  fi
  if adb devices | grep -q 'emulator-5554'; then break; fi
  sleep 2
done
python3 ci/remote_android_runtime.py 2>&1 | tee runtime-results/test-console.txt
