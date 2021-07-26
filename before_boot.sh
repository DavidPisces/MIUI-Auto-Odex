#!/system/bin/sh
MODDIR=${0%/*}
boot_log=$MODDIR/boot.log
if [[ ! -f $boot_log ]]; then
    echo 0 >"$boot_log"
    final=1
else
    first=$(cat "$boot_log")
    final="$(expr "$first" + 1)"
    echo "$final" >"$boot_log"
fi

if [[ $final -eq 2 ]]; then
    rm -rf "$MODDIR"/system/framework
    rm -rf "$MODDIR"/system/product/framework
    rm -rf "$MODDIR"/system/system_ext/framework
    reboot
fi
exit 0
