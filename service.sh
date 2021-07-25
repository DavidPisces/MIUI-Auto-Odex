#!/system/bin/sh
export PATH=/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/user/0/com.gjzs.chongzhi.online/files/usr/busybox:/dev/P5TeaG/.magisk/busybox
MODDIR=${0%/*}
VERSION=$MODDIR/now_version
pre_version=$(cat "$VERSION")
now_version=$(getprop ro.system.build.version.incremental)
if [ ”$pre_version” != "$now_version" ]; then
    touch $MODDIR/disable
    exit 0
else
    if [ $(getprop init.svc.bootanim) != "stopped" ]; then
        sleep diy
        rm -rf "$MODDIR"/system/framework
        rm -rf "$MODDIR"/system/product/framework
        rm -rf "$MODDIR"/system/system_ext/framework
        reboot
    fi
    exit 0
fi
