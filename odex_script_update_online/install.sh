SKIPMOUNT=true
PROPFILE=false
POSTFSDATA=true
LATESTARTSERVICE=true
REPLACE="
"
on_install() {
  ui_print "- 提取模块文件"
  unzip -o "$ZIPFILE" 'system/*' -d "$MODPATH" >&2
}
print_modname() {
  ui_print "**************************************************************"
  ui_print "- MIUI ODEX 脚本更新模块"
  ui_print "- Made By 柚稚的孩纸&冷洛"
  ui_print "**************************************************************"
}
rm -rf /storage/emulated/0/MIUI_odex/odex.sh
rm -rf /storage/emulated/0/MIUI_odex/odex.json
mkdir -p /storage/emulated/0/MIUI_odex
cp -f "$TMPDIR"/odex.sh /storage/emulated/0/MIUI_odex
cp -f "$TMPDIR"/odex.json /storage/emulated/0/MIUI_odex
echo -n "description=$(cat $TMPDIR/odex.md | sed '1d')" >>"$TMPDIR"/module.prop
[ ! -f /storage/emulated/0/MIUI_odex/Simple_List.prop ] && cp -f "$TMPDIR"/Simple_List.prop /storage/emulated/0/MIUI_odex