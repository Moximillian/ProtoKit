#!/bin/sh
rm -rf ./.build

swift package resolve

# Generate project
swift package generate-xcodeproj
