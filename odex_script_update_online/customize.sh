SKIPUNZIP=1
if [ "$API" -ge 28 ]; then
  ui_print "- 安卓 SDK 版本: $API"
else
  ui_print "*********************************************************"
  ui_print "! 不支持安卓 SDK 版本 $API"
  abort "*********************************************************"
fi
if [[ $KSU == true ]]; then
  ui_print "- KernelSU 用户空间当前的版本号: $KSU_VER_CODE"
  ui_print "- KernelSU 内核空间当前的版本号: $KSU_KERNEL_VER_CODE"
else
  ui_print "- Magisk 版 本: $MAGISK_VER_CODE"
  if [ "$MAGISK_VER_CODE" -lt 24000 ]; then
    ui_print "*********************************************"
    ui_print "! 请安装 Magisk 24.0+"
    abort "*********************************************"
  else
    ui_print "- Magisk 版本号: $MAGISK_VER_CODE"
  fi
fi
if [ ! -d /storage/emulated/0/Android/MIUI_odex/module_files ]; then
  mkdir -p /storage/emulated/0/Android/MIUI_odex/module_files
fi
rm -rf /data/system/package_cache/*
unzip -o "$ZIPFILE" 'module.prop' -d "$MODPATH"
unzip -o "$ZIPFILE" 'uninstall.sh' -d "$MODPATH"
unzip -o "$ZIPFILE" 'system/*' -d "$MODPATH"
unzip -o "$ZIPFILE" 'odex.sh' -d "/storage/emulated/0/Android/MIUI_odex"
unzip -o "$ZIPFILE" 'module.prop' -d "/storage/emulated/0/Android/MIUI_odex"
unzip -o "$ZIPFILE" 'META-INF/*' -d "/storage/emulated/0/Android/MIUI_odex/module_files"
unzip -o "$ZIPFILE" 'uninstall.sh' -d "/storage/emulated/0/Android/MIUI_odex/module_files"
cat >/storage/emulated/0/Android/MIUI_odex/module_files/customize.sh <<'EOF'
SKIPUNZIP=0
if [ "$API" -ge 28 ]; then
  ui_print "- 安卓 SDK 版本: $API"
else
  ui_print "*********************************************************"
  ui_print "! 不支持安卓 SDK 版本 $API"
  abort "*********************************************************"
fi
if [[ $KSU == true ]]; then
  ui_print "- KernelSU 用户空间当前的版本号: $KSU_VER_CODE"
  ui_print "- KernelSU 内核空间当前的版本号: $KSU_KERNEL_VER_CODE"
else
  ui_print "- Magisk 版 本: $MAGISK_VER_CODE"
  if [ "$MAGISK_VER_CODE" -lt 24000 ]; then
    ui_print "*********************************************"
    ui_print "! 请安装 Magisk 24.0+"
    abort "*********************************************"
  else
    ui_print "- Magisk 版本号: $MAGISK_VER_CODE"
  fi
fi
rm -rf /data/system/package_cache/*
set_perm_recursive "$MODPATH" 0 0 0755 0644
[ -d "$MODPATH"/system/vendor/app ] && set_perm_recursive "$MODPATH"/system/vendor/app 0 0 0755 0644 u:object_r:vendor_file:s0
[ -d "$MODPATH"/system/vendor/odm/app ] && set_perm_recursive "$MODPATH"/system/vendor/odm/app 0 0 0755 0644 u:object_r:vendor_file:s0
[ -d "$MODPATH"/system/vendor/framework ] && set_perm_recursive "$MODPATH"/system/vendor/framework 0 0 0755 0644 u:object_r:vendor_framework_file:s0
EOF
[ ! -f /storage/emulated/0/Android/MIUI_odex/Simple_List.prop ] && unzip -o "$ZIPFILE" 'Simple_List.prop' -d "/storage/emulated/0/Android/MIUI_odex"
[ -f /storage/emulated/0/Android/MIUI_odex/odex.json ] && rm -rf /storage/emulated/0/Android/MIUI_odex/odex.json
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH"/system/bin 0 2000 0755 0755
ui_print "- 安装完成,请重启后运行/storage/emulated/0/Android/MIUI_odex/odex.sh"
