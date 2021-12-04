#!/system/bin/sh
MODDIR=${0%/*}
boot_log=$MODDIR/boot.log
sleep diy
if [[ $(getprop init.svc.bootanim) = "stopped" ]]; then
    rm -f "$boot_log"
else
    rm -rf "$MODDIR"/system/framework
    rm -rf "$MODDIR"/system/product/framework
    rm -rf "$MODDIR"/system/system_ext/framework
    reboot
fi
