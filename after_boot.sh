#!/system/bin/sh
MODDIR=${0%/*}
boot_log=$MODDIR/boot.log
#这里下面最后“1.5”就是正常救砖时延迟的时间
sleep diy
if [[ $(getprop init.svc.bootanim) = "stopped" ]]; then
    rm -f "$boot_log"
else
    rm -rf "$MODDIR"/system/framework
    rm -rf "$MODDIR"/system/product/framework
    rm -rf "$MODDIR"/system/system_ext/framework
    reboot
fi
