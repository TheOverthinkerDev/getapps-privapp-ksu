#!/system/bin/sh
# GetApps Privileged - KernelSU/Magisk module installer
# Copies the GetApps APK into /product/priv-app/MiuiMarket at flash time,
# so the module zip itself never ships Xiaomi's APK.

SKIPUNZIP=0
PKG=com.xiaomi.market
DEST="$MODPATH/system/product/priv-app/MiuiMarket"

ui_print "- GetApps Privileged"

# 1. Find the APK: bundled apk/ folder -> /sdcard/GetApps -> installed package
APK=""
for f in "$MODPATH"/apk/*.apk /sdcard/GetApps/*.apk; do
  if [ -f "$f" ]; then APK="$f"; break; fi
done

if [ -z "$APK" ]; then
  PATHS=$(pm path "$PKG" 2>/dev/null | sed 's/^package://')
  COUNT=$(echo "$PATHS" | grep -c '\.apk$')
  if [ "$COUNT" -gt 1 ]; then
    abort "! $PKG is installed as split APKs; put a single base APK in /sdcard/GetApps/"
  fi
  APK=$(echo "$PATHS" | head -n 1)
  [ -n "$APK" ] && ui_print "- Using installed GetApps: $APK"
fi

if [ -z "$APK" ] || [ ! -f "$APK" ]; then
  abort "! GetApps APK not found. Install GetApps first, or copy its APK to /sdcard/GetApps/"
fi

# 2. Copy APK
mkdir -p "$DEST/lib/arm64"
cp -f "$APK" "$DEST/MiuiMarket.apk" || abort "! Failed to copy APK"
ui_print "- APK: $(du -h "$DEST/MiuiMarket.apk" | cut -f1)"

# 3. System apps do not extract native libs; unpack arm64 libs next to the APK
unzip -oj "$DEST/MiuiMarket.apk" 'lib/arm64-v8a/*.so' -d "$DEST/lib/arm64" >/dev/null 2>&1
LIBS=$(ls "$DEST/lib/arm64" 2>/dev/null | wc -l)
ui_print "- Native libs (arm64): $LIBS"
[ "$LIBS" -eq 0 ] && rm -rf "$DEST/lib"

rm -rf "$MODPATH/apk"

set_perm_recursive "$MODPATH/system" 0 0 0755 0644

ui_print "- Done. Reboot to apply."
ui_print "- If GetApps crashes on launch: KernelSU > Superuser > GetApps"
ui_print "  > App Profile Custom > turn OFF 'Umount modules'."
