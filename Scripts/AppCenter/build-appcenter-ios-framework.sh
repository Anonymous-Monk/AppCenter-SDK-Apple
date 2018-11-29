#!/bin/sh

# Sets the target folders and the final framework product.
FMK_NAME=AppCenter
TGT_NAME=${FMK_NAME}IOS

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
PRODUCTS_DIR=${SRCROOT}/../AppCenter-SDK-Apple/iOS
INSTALL_DIR=${PRODUCTS_DIR}/${FMK_NAME}.framework

# Working dir will be deleted after the framework creation.
WRK_DIR=build
DEVICE_DIR=${WRK_DIR}/Release-iphoneos
SIMULATOR_DIR=${WRK_DIR}/Release-iphonesimulator

# Make sure we're inside $SRCROOT
cd "${SRCROOT}"

# Cleaning previous build
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}" clean

# Building both architectures.
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}" -sdk iphoneos
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}" -sdk iphonesimulator

# Cleaning the oldest.
if [ -d "${INSTALL_DIR}" ]
then
rm -rf "${INSTALL_DIR}"
fi

# Creates and renews the final product folder.
mkdir -p "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}/Headers"
mkdir -p "${INSTALL_DIR}/Modules"

# Copy the swift import file
cp -f "${SRCROOT}/${FMK_NAME}/Support/iOS.modulemap" "${INSTALL_DIR}/Modules/module.modulemap"

# Copies the headers and resources files to the final product folder.
cp -R "${SRCROOT}/${WRK_DIR}/Release-iphoneos/include/${FMK_NAME}/" "${INSTALL_DIR}/Headers/"

# Create the arm64e slice in Xcode 10.1 and lipo it with the device binary that was created with oldest supported Xcode version.
# Move binary that was create with old Xcode to temp location.
LIB_IPHONEOS_TEMP_DIR="${DEVICE_DIR}/temp"
mkdir -p "${LIB_IPHONEOS_TEMP_DIR}"
mv "${DEVICE_DIR}/lib${FMK_NAME}.a" "${LIB_IPHONEOS_TEMP_DIR}/lib${FMK_NAME}.a"

LIB_IPHONEOS_FINAL="${DEVICE_DIR}/lib${FMK_NAME}.a"

# Build with the Xcode version that supports arm64e.
env DEVELOPER_DIR="/Applications/Xcode.app" /usr/bin/xcodebuild ARCHS="arm64e" -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}"

# Lipo the binaries that were built from various Xcode versions.
lipo -create "${LIB_IPHONEOS_FINAL}" "${LIB_IPHONEOS_TEMP_DIR}/lib${FMK_NAME}.a"  -output "${LIB_IPHONEOS_FINAL}"

# Uses the Lipo tool to merge both binary files (i386/x86_64 + armv7/armv7s/arm64/arm64e) into one universal final product.
lipo -create "${LIB_IPHONEOS_FINAL}" "${SIMULATOR_DIR}/lib${FMK_NAME}.a" -output "${INSTALL_DIR}/${FMK_NAME}"

rm -r "${WRK_DIR}"

# Copy license and readme
cp -f "${SRCROOT}/../LICENSE" "${PRODUCTS_DIR}"
cp -f "${SRCROOT}/../README.md" "${PRODUCTS_DIR}"
cp -f "${SRCROOT}/../CHANGELOG.md" "${PRODUCTS_DIR}"
