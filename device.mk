#
# Copyright (C) 2021-2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# xigua: Self-heal a stale recovery prop.default. Incremental builds were
# observed to keep a 3-line prop.default (missing vendor.display.* config),
# causing recovery black screen. Check at make-parse time and remove the
# incomplete file so ninja rebuilds it from the 5 build.prop files.
# The $(shell date) changes the command string so kati does not cache it.
$(eval _xigua_prop_check := $(shell bash $(LOCAL_PATH)/check_recovery_prop.sh; date > /dev/null))

# AAPT
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Audio
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    $(LOCAL_PATH)/configs/audio/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml

# Boot animation
TARGET_SCREEN_HEIGHT := 2772
TARGET_SCREEN_WIDTH := 1240

# Display
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/display/displayconfig.xml:$(TARGET_COPY_OUT_VENDOR)/etc/displayconfig/display_id_4630947194812807555.xml

$(call soong_config_set,qtidisplay,pxlw_vendor_namespace,vendor/oneplus/xigua)
# xigua: iris7 — kernel CONFIG_PXLW_IRIS=n + DSI1 disabled, but HAL must keep
# pxlw_vendor_namespace set because libpwirisfeature's static constructors are
# required for SDM core init. pxlw_hw_iris7=false keeps SUPPORTS_PXLW_IRIS7 off.
# 2026-08-14 notes:
# - pxlw_hw_iris7=true under iris7-disabled kernel caused boot white-flash +
#   WeChat image-open white-flash crash. Reverted to false (stable).
# - WeChat images appear yellow-tinted, but ONLY in WeChat (other apps normal),
#   and this is independent of pxlw_hw_iris7 (false also shows it; whether the
#   pre-experiment vendor was truly unaffected is unconfirmed). Root cause not
#   isolated [需要人工补充]. Deferred (user decision 2026-08-14).
# - WeChat image-open white-flash/crash traced to a third-party display
#   optimization module, not to these ROM changes.
$(call soong_config_set_bool,qtidisplay,pxlw_hw_iris7,false)

PRODUCT_SYSTEM_PROPERTIES += \
    sys.brightness.disable_gamma_conversion=true

# Fingerprint
TARGET_HAS_UDFPS := true

# IR
#$(call inherit-product, vendor/oneplus/ir/config.mk)

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.consumerir.xml

PRODUCT_PACKAGES += \
    android.hardware.ir-service.oplus

# Fingerprint
$(call soong_config_set,surfaceflinger,udfps_lib,//hardware/oplus:libudfps_extension.oplus)
$(call soong_config_set_bool,qtidisplay,oplus_udfps,true)

# LiveDisplay
$(call soong_config_set_bool,OPLUS_LINEAGE_LIVEDISPLAY_HAL,ENABLE_AF,true)
$(call soong_config_set_bool,OPLUS_LINEAGE_LIVEDISPLAY_HAL,ENABLE_SE,false)

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay-lineage

PRODUCT_PACKAGES += \
    OPlusFrameworksResTarget \
    OPlusSettingsProviderResTarget \
    OPlusSettingsResTarget \
    OPlusSystemUIResTarget \
    OPlusWifiResTarget

# Power
$(call soong_config_set,qtipower,mode_ext_lib,power-ext-oplus)

# Regional properties
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/vendor/odm/etc/22851/build.default.prop:$(TARGET_COPY_OUT_ODM)/etc/22851/build.default.prop

# Sensors
PRODUCT_PACKAGES += \
    sensors.oplus

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Touch
$(call soong_config_set_bool,OPLUS_LINEAGE_TOUCH_HAL,USE_OPLUSTOUCH,true)

# Vibrator
PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator.service.oplus

$(call soong_config_set_bool,OPLUS_LINEAGE_VIBRATOR_HAL,USE_EFFECT_STREAM,true)

# Inherit from the common OEM chipset makefile.
$(call inherit-product, device/oneplus/sm8550-common/common.mk)

# Inherit from the proprietary files makefile.
$(call inherit-product, vendor/oneplus/xigua/xigua-vendor.mk)
#PRODUCT_PACKAGES += GoogleCamera (Pixel版需要GMS，不可用)
# Gboard removal - use TARGET_INCLUDE_GOOGLEIME=false instead
# PRODUCT_PACKAGES := $(filter-out ...)
PRODUCT_PACKAGES := $(filter-out LatinIME,$(PRODUCT_PACKAGES))
