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
export FOX_MAINTAINER_PATCH_VERSION="1"
export OF_FLASHLIGHT_ENABLE=1
export OF_FL_PATH1="/sys/devices/virtual/flashlight_core/flashlight/flashlight_torch"

AVATAR_SRC="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/maintainer.png"
AVATAR_DST="bootable/recovery/gui/theme/portrait_hdpi/images/Default/About/maintainer.png"
if [ -f "$AVATAR_SRC" ] && [ -f "$AVATAR_DST" ]; then
    cp -f "$AVATAR_SRC" "$AVATAR_DST" && echo "OK: maintainer avatar replaced"
else
    echo "-- warning: avatar not replaced (src: $AVATAR_SRC, dst: $AVATAR_DST)"
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
export FOX_ENABLE_APP_MANAGER=1
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
    local patch="$1" err
    if [ ! -f "$patch" ]; then
        echo "ERROR: patch file not found: $patch"
        return 1
    fi
    if err=$(git -C bootable/recovery apply --ignore-whitespace --check "$patch" 2>&1); then
        git -C bootable/recovery apply --ignore-whitespace "$patch" && echo "OK: applied $(basename "$patch")"
    elif git -C bootable/recovery apply --ignore-whitespace --reverse --check "$patch" > /dev/null 2>&1; then
        echo "OK: already applied $(basename "$patch")"
    else
        echo "ERROR: cannot apply $(basename "$patch"):"
        echo "$err"
    fi
}

apply_recovery_patch "$DEVICE_DIR/patches/0003-vibrator_single-haptics.patch"
apply_recovery_patch "$DEVICE_DIR/patches/0002-MediaTek-flashlight_core-support.patch"
