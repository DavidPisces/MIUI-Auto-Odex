MODDIR=${0%/*}
touch $MODDIR/now_version
modelversion="$(getprop ro.system.build.version.incremental)"
echo "$modelversion" >$MODDIR/now_version