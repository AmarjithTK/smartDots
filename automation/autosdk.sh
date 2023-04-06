#!/bin/bash


# Set environment variables
echo 'export ANDROID_SDK_ROOT="$HOME/Android/sdk"' >> ~/.zshrc
echo 'export PATH="$PATH:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/platform-tools"' >> ~/.zshrc

source ~/.zshrc


# Download and extract Android SDK
wget https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -O android-sdk.zip
mkdir -p $ANDROID_SDK_ROOT/cmdline-tools
unzip -q android-sdk.zip -d $ANDROID_SDK_ROOT/cmdline-tools/
mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest

# Install platform tools and build tools
yes | sdkmanager "platform-tools"
yes | sdkmanager "build-tools;33.0.1"
yes | sdkmanager "platforms;android-33"

# Install required SDKs
yes | sdkmanager "platforms;android-33"


# # Install required system images
# yes | sdkmanager "system-images;android-31;google_apis;x86_64"
# yes | sdkmanager "system-images;android-30;google_apis;x86_64"
# yes | sdkmanager "system-images;android-29;google_apis;x86_64"
# yes | sdkmanager "system-images;android-28;google_apis;x86_64"

# # Create an AVD (Android Virtual Device)
# echo no | avdmanager create avd --name test --package "system-images;android-31;google_apis;x86_64" --device "pixel_3a" --tag "google_apis" --abi "x86_64"
