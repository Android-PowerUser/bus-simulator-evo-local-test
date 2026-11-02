FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive ANDROID_HOME=/opt/android-sdk ANDROID_SDK_ROOT=/opt/android-sdk
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 openjdk-17-jre-headless ca-certificates libgl1 libegl1 libnss3 \
    libx11-6 libxcb1 libxcomposite1 libxcursor1 libxi6 libxtst6 libpulse0 \
    libasound2t64 libxdamage1 libxrandr2 libgbm1 libdrm2 unzip \
    && rm -rf /var/lib/apt/lists/*
ENV PATH=/opt/android-sdk/platform-tools:/opt/android-sdk/emulator:/usr/bin:/bin \
    ANDROID_AVD_HOME=/tmp/android/avd ANDROID_USER_HOME=/tmp/android \
    ANDROID_SERIAL=emulator-5554 GITHUB_WORKSPACE=/workspace
WORKDIR /workspace
ENTRYPOINT ["bash", "ci/docker/run.sh"]
