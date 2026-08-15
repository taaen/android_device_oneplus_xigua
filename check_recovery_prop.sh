#!/bin/bash
#
# xigua: Check recovery ramdisk prop.default completeness.
#
# Background: incremental builds were observed to keep a stale 3-line
# prop.default (ro.debuggable/ro.adb.secure/persist.sys.usb.config) in
# out/target/product/xigua/recovery/root/, missing all vendor.display.*
# display config. Flashing a recovery built with that file causes black
# screen (display init fails).
#
# This script removes a too-short prop.default so ninja rebuilds it from
# the 5 build.prop files. Invoked from device.mk via $(shell) at parse time.
#
# Exit 0 always (build must not fail; this is a self-heal, not a gate).

set -e

OUT_DIR="${OUT_DIR:-out/target/product/xigua}"
PROP="${OUT_DIR}/recovery/root/prop.default"

if [ ! -f "${PROP}" ]; then
  # File absent — ninja will build it. Nothing to do.
  exit 0
fi

lines=$(wc -l < "${PROP}")
# A complete prop.default merges 5 build.prop files (system/vendor/odm/
# product/system_ext) + recovery UI props; normally 600+ lines.
if [ "${lines}" -lt 100 ]; then
  echo "xigua: warning: recovery prop.default is incomplete (${lines} lines < 100), removing for rebuild"
  rm -f "${PROP}"
fi

exit 0
