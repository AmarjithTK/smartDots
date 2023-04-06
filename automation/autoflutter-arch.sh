#!/bin/zsh

# Flutter version to install
FLUTTER_VERSION="3.7.9"

# Android SDK version to install
ANDROID_SDK_VERSION="9477386"

# Install required dependencies
sudo pacman -Syu --noconfirm curl git unzip jdk-openjdk

# Install Flutter
cd ~
curl -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter.tar.xz
rm flutter.tar.xz
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Install Android SDK
cd $HOME
mkdir -p android-sdk/cmdline-tools/latest
mkdir -p android-sdk/temp
cd android-sdk
curl -o sdk-tools-linux.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip
unzip  sdk-tools-linux.zip -d $HOME/android-sdk/temp
mv $HOME/android-sdk/temp/cmdline-tools/* $HOME/android-sdk/cmdline-tools/latest/

# rm sdk-tools-linux.zip
echo 'export ANDROID_HOME="$HOME/android-sdk"' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools"' >> ~/.zshrc
echo 'export PATH="$HOME/android-sdk/cmdline-tools/latest/bin:$PATH"' >> ~/.zshrc

echo 'export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"' >> ~/.zshrc
source ~/.zshrc

# Accept Android SDK licenses
yes | sdkmanager --licenses --sdk_root=$HOME/android-sdk
# sdkmanager --install "cmdline-tools;latest"
# Install Android SDK components
sdkmanager --sdk_root=$HOME/android-sdk "platform-tools" "platforms;android-33" "build-tools;33.0.1"
sudo pacman -Syu --noconfirm ninja clang

flutter config --android-sdk=$HOME/android-sdk
# Run Flutter doctor to verify installation
flutter doctor


# Install Android Studio
# cd ~
# curl -o android-studio.tar.gz https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2020.3.1.0/android-studio-2020.3.1.0-linux.tar.gz
# tar xf android-studio.tar.gz
# rm android-studio.tar.gz

# # Configure Android Studio for Flutter development
# cd ~/android-studio/bin
# ./studio.sh
# echo 'export PATH="$HOME/android-studio/bin:$PATH"' >> ~/.zshrc
# source ~/.zshrc

# Install Flutter and Dart plugins
~/flutter/bin/flutter pub global activate --source hosted protoc_plugin
~/flutter/bin/flutter pub global activate grpc_tools
~/flutter/bin/flutter pub global activate protoc_plugin
~/flutter/bin/flutter pub global activate protoc_plugin
~/flutter/bin/flutter pub global activate protoc_plugin
~/flutter/bin/flutter pub global activate protoc_plugin
~/flutter/bin/flutter pub global activate protoc_plugin
~/flutter/bin/flutter pub global activate protoc_plugin
~/flutter/bin/flutter pub global activate protoc_plugin

# Restart Android Studio and create a new Flutter project
# ./studio.sh &
