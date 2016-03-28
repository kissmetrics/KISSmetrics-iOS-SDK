#!/bin/sh
#       ============Script Start==============
if [ "${ACTION}" = "build" ]
then
# Set the target folders and the final framework product.
INSTALL_DIR=${PROJECT_DIR}/../KISSmetricsSDK.framework
DEVICE_DIR=${SYMROOT}/Release-iphoneos
SIMULATOR_DIR=${SYMROOT}/Release-iphonesimulator

# Create and renews the final product folder.
mkdir -p "${INSTALL_DIR}"
rm -rf "${INSTALL_DIR}"
rm -rf "${INSTALL_DIR}/KISSmetricsSDK"

# Copy the header files to the final product folder.
ditto "${DEVICE_DIR}/KISSmetricsSDK.framework/Headers" "${INSTALL_DIR}/Headers"

# Use the Lipo Tool to merge both binary files (i386 + armv6/armv7) into one Universal final product.
lipo -create "${DEVICE_DIR}/KISSmetricsSDK.framework/KISSmetricsSDK" "${SIMULATOR_DIR}/KISSmetricsSDK.framework/KISSmetricsSDK" -output "${INSTALL_DIR}/KISSmetricsSDK"
fi
#       ============Script End==============
