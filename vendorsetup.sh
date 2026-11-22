#!/bin/bash

export BUILD_USERNAME=knukima
export BUILD_HOSTNAME=knukimas-runner

export OF_DISABLE_OTA_MENU=1
export FOX_AB_DEVICE=1
export FOX_VIRTUAL_AB_DEVICE=1
export OF_DEFAULT_KEYMASTER_VERSION=4.1
export OF_NO_TREBLE_COMPATIBILITY_CHECK=1
export OF_MAINTAINER="knukima"
export FOX_VARIANT="R12.0_knukima"
export OF_FLASHLIGHT_ENABLE=1
export OF_FL_PATH1="/sys/devices/virtual/flashlight_core/flashlight/flashlight_torch"

OF_AVATAR_FILE="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/maintainer.png"
if [ -f "$OF_AVATAR_FILE" ]; then
    export OF_MAINTAINER_AVATAR="$OF_AVATAR_FILE"
else
    echo "-- warning: $OF_AVATAR_FILE not found, avatar will not be shown"
fi

export FOX_USE_BASH_SHELL=1
export FOX_USE_NANO_EDITOR=1
export FOX_USE_TAR_BINARY=1
export FOX_USE_SED_BINARY=1
export FOX_USE_XZ_UTILS=1
export FOX_ASH_IS_BASH=1
export OF_ENABLE_LPTOOLS=1
export FOX_DELETE_MAGISK_ADDON=1
export FOX_DELETE_AROMAFM=1
export FOX_ENABLE_APP_MANAGER=0
export OF_SUPPORT_VBMETA_AVB2_PATCHING=1

export FOX_USE_DATA_RECOVERY_FOR_SETTINGS=1

export OF_LOOP_DEVICE_ERRORS_TO_LOG=1

export OF_USE_LZ4_COMPRESSION=true

export OF_SCREEN_H=2400
export OF_STATUS_H=95
export OF_STATUS_INDENT_LEFT=48
export OF_STATUS_INDENT_RIGHT=48
export OF_ALLOW_DISABLE_NAVBAR=0
export OF_CLOCK_POS=1

export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_MAXSIZE="5G"
export CCACHE_DIR=".ccache"

if [ ! -d ${CCACHE_DIR} ]; then
  mkdir $CCACHE_DIR
fi

export LC_ALL="C"

# Clone to fix build on minimal manifest
git clone https://android.googlesource.com/platform/external/gflags/ -b android-12.1.0_r4 external/gflags

# Patches
DEVICE_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

apply_recovery_patch() {
    local patch="$1"
    if git -C bootable/recovery apply --check "$patch" > /dev/null 2>&1; then
        git -C bootable/recovery apply "$patch" && echo "OK: applied $(basename "$patch")"
    elif git -C bootable/recovery apply --reverse --check "$patch" > /dev/null 2>&1; then
        echo "OK: already applied $(basename "$patch")"
    else
        echo "ERROR: cannot apply $(basename "$patch")"
    fi
}

apply_recovery_patch "$(pwd)/device/transsion/mt6789-common/patches/0001-Change-haptics-activation-file-path.patch"
apply_recovery_patch "$DEVICE_DIR/patches/0002-MediaTek-flashlight_core-support.patch"
