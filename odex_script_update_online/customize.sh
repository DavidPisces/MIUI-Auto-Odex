SKIPUNZIP=0
SDK=$(getprop ro.system.build.version.sdk)
if [ "$SDK" -ge 28 ]; then
  ui_print "- Android SDK version: $SDK"
else
  ui_print "*********************************************************"
  ui_print "! Unsupported Android SDK version $SDK"
  abort "*********************************************************"
fi
ui_print "- Magisk version: $MAGISK_VER_CODE"
if [ "$MAGISK_VER_CODE" -lt 24000 ]; then
  ui_print "*********************************************************"
  ui_print "! Please install Magisk 24.0+"
  abort "*********************************************************"
fi
if [ ! -d /storage/emulated/0/MIUI_odex ]; then
  mkdir -p /storage/emulated/0/MIUI_odex
else
  [ -f /storage/emulated/0/MIUI_odex/odex.sh ] && rm -rf /storage/emulated/0/MIUI_odex/odex.sh
  [ -f /storage/emulated/0/MIUI_odex/odex.json ] && rm -rf /storage/emulated/0/MIUI_odex/odex.json
fi
cp -f "$MODPATH"/odex.sh /storage/emulated/0/MIUI_odex && rm -rf "$MODPATH"/odex.sh
[ ! -f /storage/emulated/0/MIUI_odex/Simple_List.prop ] && cp -f "$MODPATH"/Simple_List.prop /storage/emulated/0/MIUI_odex
rm -rf "$MODPATH"/Simple_List.prop
rm -rf "$MODPATH"/system.prop
