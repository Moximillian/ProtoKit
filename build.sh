#!/bin/sh

rm -rf ./.build

# Build ProtoKit
export BUILDDIR="./.build"
xcodebuild -target ProtoKit -configuration Release -destination "platform=iOS Simulator,OS=10.0,name=iPhone 6" IPHONEOS_DEPLOYMENT_TARGET=10.0 TARGET_BUILD_DIR=$BUILDDIR clean build

export BUILDDIR="./.build/build-x86"
xcodebuild -target ProtoKit -arch x86_64 -sdk iphonesimulator -configuration Release -destination "platform=iOS Simulator,OS=10.0,name=iPhone 6" IPHONEOS_DEPLOYMENT_TARGET=10.0 TARGET_BUILD_DIR=$BUILDDIR VALID_ARCHS=x86_64 clean build

# copy x86_64 module maps
cp ./.build/build-x86/ProtoKit.framework/Modules/ProtoKit.swiftmodule/* ./.build/ProtoKit.framework/Modules/ProtoKit.swiftmodule/

# lipo archs together
cd ./.build/ProtoKit.framework/
mv ProtoKit ProtoKit-arm
lipo -create -output ProtoKit ProtoKit-arm ../build-x86/ProtoKit.framework/ProtoKit
rm ProtoKit-arm
cd ../..

# Clean up intermediary build files
rm -rf ./.build/build-x86
rm -rf ./build
