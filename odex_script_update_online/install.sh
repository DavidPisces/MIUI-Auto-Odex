SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=true
LATESTARTSERVICE=false
REPLACE="
"
on_install(){
  ui_print "- 提取模块文件"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
}
print_modname() {
ui_print "**************************************************************"
ui_print "- MIUI ODEX 脚本更新模块"
ui_print "- Made By 柚稚的孩纸&雄氏老方"
ui_print "**************************************************************"
}
touch $TMPDIR/now_version
modelversion="$(getprop ro.system.build.version.incremental)"
echo "$modelversion" >>$TMPDIR/now_version
rm -rf /storage/emulated/0/MIUI_odex/odex.sh
rm -rf /storage/emulated/0/MIUI_odex/odex.json
cp -f $TMPDIR/odex.sh /storage/emulated/0/MIUI_odex
cp -f $TMPDIR/odex.json /storage/emulated/0/MIUI_odex
echo -n "description=$(cat $TMPDIR/odex.md | sed '1d')">>$TMPDIR/module.prop