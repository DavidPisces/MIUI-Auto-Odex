#!/system/bin/sh
MODDIR=${0%/*}
export PATH="/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/user/0/com.gjzs.chongzhi.online/files/usr/busybox:/dev/P5TeaG/.magisk/busybox"
VERSION=$MODDIR/now_version
pre_version=$(cat "$VERSION")
now_version=$(getprop ro.system.build.version.incremental)
if [ "$pre_version" != "$now_version" ]; then
    touch "$MODDIR"/disable
else
    /system/bin/sh "$MODDIR"/after_boot.sh
fi
exit 0
