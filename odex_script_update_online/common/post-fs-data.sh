MODDIR=${0%/*}
new_version="$(getprop ro.system.build.version.incremental)"
preview_version="$(cat $MODDIR/now_version)"
if [ $new_version != $preview_version ]; then
    touch /data/adb/modules/miuiodex/disable
fi