#!/bin/sh

TRG=11.0
PKG=ProtoKit
COMMONARGS="-configuration Release -project $PKG.xcodeproj -target $PKG IPHONEOS_DEPLOYMENT_TARGET=$TRG"
rm -rf ./.build

swift package resolve

# Build ProtoKit

BUILDDIR="./.build"
SDK=iphoneos
ARCH=arm64
xcodebuild -arch $ARCH -sdk $SDK $COMMONARGS TARGET_BUILD_DIR=$BUILDDIR FRAMEWORK_SEARCH_PATHS=$BUILDDIR VALID_ARCHS=$ARCH build

BUILDDIR="./.build/build-x86"
SDK=iphonesimulator
ARCH=x86_64
xcodebuild -arch $ARCH -sdk $SDK $COMMONARGS TARGET_BUILD_DIR=$BUILDDIR FRAMEWORK_SEARCH_PATHS=$BUILDDIR VALID_ARCHS=$ARCH build

# copy x86_64 module maps
cp ./.build/build-x86/$PKG.framework/Modules/$PKG.swiftmodule/* ./.build/$PKG.framework/Modules/$PKG.swiftmodule/

# lipo archs together
cd ./.build/$PKG.framework/
mv $PKG ${PKG}-arm
lipo -create -output $PKG ${PKG}-arm ../build-x86/$PKG.framework/$PKG
rm ${PKG}-arm
cd ../..

# Clean up intermediary build files
rm -rf ./.build/build-x86
rm -rf ./build
