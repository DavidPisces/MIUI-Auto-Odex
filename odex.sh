#!/bin/bash
# MIUI ODEX项目贡献者：柚稚的孩纸(zjw2017) & 冷洛(DavidPisces)
logfile=/storage/emulated/0/Android/MIUI_odex/log
success_count=0
failed_count=0
MIUI_version_code=$(getprop ro.miui.ui.version.code)
MIUI_version_name=$(getprop ro.miui.ui.version.name)
modelversion="$(getprop ro.system.build.version.incremental)"
MODPATH=/data/adb/modules/miuiodex
now_time=$(date '+%Y%m%d_%H:%M:%S')
SDK=$(getprop ro.system.build.version.sdk)
time=$(date "+%Y年%m月%d日%H:%M:%S")
version=$(cat /data/adb/modules/odex_script_update_online/module.prop | grep -w "version" | cut -d '=' -f2)
versionCode=$(cat /data/adb/modules/odex_script_update_online/module.prop | grep -w "versionCode" | cut -d '=' -f2)
# MIUI ODEX自定义配置文件目录
mkdir -p /storage/emulated/0/Android/MIUI_odex
if [[ $SDK == 28 ]]; then
   android_version=9
elif [[ $SDK == 29 ]]; then
   android_version=10
elif [[ $SDK == 30 ]]; then
   android_version=11
elif [[ $SDK == 31 ]]; then
   android_version=12
elif [[ $SDK == 32 ]]; then
   android_version=12L
elif [[ $SDK == 33 ]]; then
   android_version=13
fi
if [[ $MIUI_version_code == 14 ]] && [[ $MIUI_version_name == V140 ]]; then
   MIUI_version=14
elif [[ $MIUI_version_code == 13 ]] && [[ $MIUI_version_name == V130 ]]; then
   MIUI_version=13
elif [[ $MIUI_version_code == 12 ]] && [[ $MIUI_version_name == V125 ]]; then
   MIUI_version=12.5 Enhanced
elif [[ $MIUI_version_code == 11 ]] && [[ $MIUI_version_name == V125 ]]; then
   MIUI_version=12.5
elif [[ $MIUI_version_code == 10 ]] && [[ $MIUI_version_name == V12 ]]; then
   MIUI_version=12
elif [[ $MIUI_version_code == 9 ]] && [[ $MIUI_version_name == V11 ]]; then
   MIUI_version=11
fi
mkdir -p $logfile
echo "$(pm list packages -f -a | grep -v verlay)" >/storage/emulated/0/Android/MIUI_odex/packages.txt
sed -i -e 's/\ /\\\n/g' -e 's/\\//g' -e 's/package://g' /storage/emulated/0/Android/MIUI_odex/packages.txt
touch "$logfile"/MIUI_odex_"$now_time".log
clear
echo "*************************************************"
echo " "
echo " "
echo "                   MIUI ODEX"
echo "                       $version"
echo " "
echo " "
echo "*************************************************"
echo -e "\n- 请输入选项\n"
echo "[1] Simple (耗时较少,占用空间少，仅编译重要应用)"
echo "[2] Complete (耗时较长，占用空间大，完整编译)"
echo "[3] Skip ODEX (不进行ODEX编译)"
echo -e "\n请输入选项"
read -r choose_odex
case $choose_odex in
1 | 2)
   odex_module=true
   rm -rf /data/adb/modules/miuiodex
   [ -d "/system/product/app" ] && mkdir -p "$MODPATH"/system/product/app && is_product=0
   [ -d "/system/product/priv-app" ] && mkdir -p "$MODPATH"/system/product/priv-app
   [ -d "/system/product/framework" ] && mkdir -p "$MODPATH"/system/product/framework
   [ -d "/system/system_ext/app" ] && mkdir -p "$MODPATH"/system/system_ext/app && is_system_ext=0
   [ -d "/system/system_ext/priv-app" ] && mkdir -p "$MODPATH"/system/system_ext/priv-app
   [ -d "/system/system_ext/framework" ] && mkdir -p "$MODPATH"/system/system_ext/framework
   [ -d "/system/vendor/app" ] && mkdir -p "$MODPATH"/system/vendor/app && is_vendor=0
   clear
   echo "*************************************************"
   echo " "
   echo " "
   echo "                   MIUI ODEX"
   echo "                       $version"
   echo " "
   echo "*************************************************"
   echo -e "\n- 您希望以什么模式进行Dex2oat\n"
   echo "[1] Speed (快速编译,耗时较短)"
   echo "[2] Everything (完整编译,耗时较长)"
   echo "[3] Skip Dex2oat (不进行Dex2oat编译)"
   echo -e "\n请输入选项"
   read -r choose_dex2oat
   case $choose_dex2oat in
   1)
      dex2oat_mode=speed
      ;;
   2)
      dex2oat_mode=everything
      ;;
   3)
      dex2oat_mode=null
      ;;
   *)
      echo "输入错误，请重新输入"
      exit
      ;;
   esac
   clear
   ;;
3)
   odex_module=false
   clear
   echo "- 跳过ODEX编译，不会生成模块"
   echo "*************************************************"
   echo " "
   echo " "
   echo "                   MIUI ODEX"
   echo "                       $version"
   echo " "
   echo "*************************************************"
   echo -e "\n- 您希望以什么模式进行Dex2oat\n"
   echo "[1] Speed (快速编译,耗时较短)"
   echo "[2] Everything (完整编译,耗时较长)"
   echo "[3] Skip Dex2oat (不进行Dex2oat编译)"
   echo -e "\n请输入选项"
   read -r choose_dex2oat
   case $choose_dex2oat in
   1)
      dex2oat_mode=speed
      ;;
   2)
      dex2oat_mode=everything
      ;;
   3)
      dex2oat_mode=null
      ;;
   *)
      echo "输入错误，请重新输入"
      exit
      ;;
   esac
   clear
   ;;
*)
   echo "输入错误，请重新输入"
   exit
   ;;
esac
if [[ "$choose_odex" != 3 ]]; then
   echo "- 开始处理/system/framework"
   for a in $(ls -l /system/framework | awk 'NR>1 {print $NF}'); do
      mkdir -p $MODPATH/system/framework/oat/arm $MODPATH/system/framework/oat/arm64
      jarhead=${a%.*}
      if [ -f /system/framework/"$jarhead".jar ]; then
         echo "- 开始处理$a"
         dex2oat --dex-file=/system/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$MODPATH/system/framework/oat/arm64/"$jarhead".odex
         dex2oat --dex-file=/system/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm --oat-file=$MODPATH/system/framework/oat/arm/"$jarhead".odex
         echo "- 已完成对$a的处理"
      fi
   done
   if [ "$is_product" == 0 ]; then
      echo "- 开始处理/system/product/framework"
      for b in $(ls -l /system/product/framework | awk 'NR>1 {print $NF}'); do
         mkdir -p $MODPATH/system/product/framework/oat/arm $MODPATH/system/product/framework/oat/arm64
         jarhead=${b%.*}
         if [ -f /system/product/framework/"$jarhead".jar ]; then
            echo "- 开始处理$b"
            dex2oat --dex-file=/system/product/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$MODPATH/system/product/framework/oat/arm64/"$jarhead".odex
            dex2oat --dex-file=/system/product/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm --oat-file=$MODPATH/system/product/framework/oat/arm/"$jarhead".odex
            echo "- 已完成对$b的处理"
         fi
      done
   fi
   if [ "$is_system_ext" == 0 ]; then
      echo "- 开始处理/system/system_ext/framework"
      for c in $(ls -l /system/system_ext/framework | awk 'NR>1 {print $NF}'); do
         mkdir -p $MODPATH/system/system_ext/framework/oat/arm $MODPATH/system/system_ext/framework/oat/arm64
         jarhead=${c%.*}
         if [ -f /system/system_ext/framework/"$jarhead".jar ]; then
            echo "- 开始处理$c"
            dex2oat --dex-file=/system/system_ext/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$MODPATH/system/system_ext/framework/oat/arm64/"$jarhead".odex
            dex2oat --dex-file=/system/system_ext/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm --oat-file=$MODPATH/system/system_ext/framework/oat/arm/"$jarhead".odex
            echo "- 已完成对$c的处理"
         fi
      done
   fi
   if [[ "$choose_odex" == 1 ]]; then
      echo "- 正在以Simple(简单)模式编译"
      for app_list in $(cat /storage/emulated/0/Android/MIUI_odex/Simple_List.prop | grep -v "#"); do
         var=$app_list
         record="$(eval cat /storage/emulated/0/Android/MIUI_odex/packages.txt | grep "$var"$)"
         apk_path="${record%=*}"
         apk_dir="${apk_path%/*}"
         apk_name="${apk_path##*/}"
         apk_name="${apk_name%.*}"
         apk_source="$(echo "$apk_dir" | cut -d"/" -f2)"
         echo "- 开始处理$app_list"
         if [[ "$(unzip -l "$apk_path" | grep lib/)" == "" ]] || [[ "$(unzip -l "$apk_path" | grep lib/arm64)" != "" ]]; then
            apk_abi=arm64
            echo "- 该应用为64位应用"
         else
            apk_abi=arm
            echo "- 该应用为32位应用"
         fi
         if [[ "$apk_source" == "data" ]]; then
            if [ "$(unzip -l "$apk_path" | grep classes.dex)" != "" ]; then
               rm -rf "$apk_dir"/oat/"$apk_abi"/*
               dex2oat --dex-file="$apk_path" --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$apk_dir"/oat/"$apk_abi"/base.odex
               echo "- 已完成对$app_list的odex分离处理"
            fi
         else
            if [ "$(unzip -l "$apk_path" | grep classes.dex)" != "" ]; then
               mkdir -p "$MODPATH""$apk_dir"/oat/"$apk_abi"
               dex2oat --dex-file="$apk_path" --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH""$apk_dir"/oat/"$apk_abi"/"$apk_name".odex
               echo "- 已完成对$app_list的odex分离处理"
            fi
         fi
      done
   elif [[ "$choose_odex" == 2 ]]; then
      echo "- 开始处理/system/app"
      for d in $(ls -l /system/app | awk '/^d/ {print $NF}'); do
         if [ -f /system/app/"$d"/"$d".apk ]; then
            if [ "$(unzip -l /system/app/"$d"/"$d".apk | grep classes.dex)" != "" ]; then
               echo "! 已检测到dex文件，开始编译"
               if [[ "$(unzip -l /system/app/"$d"/"$d".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /system/app/"$d"/"$d".apk | grep lib/arm64)" != "" ]]; then
                  apk_abi=arm64
                  echo "- 该应用为64位应用"
               else
                  apk_abi=arm
                  echo "- 该应用为32位应用"
               fi
               mkdir -p "$MODPATH"/system/app/"$d"/oat/"$apk_abi"
               echo "- 开始处理$d"
               dex2oat --dex-file=/system/app/"$d"/"$d".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/app/"$d"/oat/"$apk_abi"/"$d".odex
               echo "- 已完成对$d的odex分离处理"
               ((success_count++))
            else
               echo "! 未检测到dex文件，跳过编译"
               ((failed_count++))
               echo "/system/app/$d/$d.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
            fi
         else
            echo "! 编译$d失败，没有apk文件"
            echo "/system/app/$d/$d.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
            ((failed_count++))
         fi
      done
      echo "- 开始处理/system/priv-app"
      for e in $(ls -l /system/priv-app | awk '/^d/ {print $NF}'); do
         if [ -f /system/priv-app/"$e"/"$e".apk ]; then
            if [ "$(unzip -l /system/priv-app/"$e"/"$e".apk | grep classes.dex)" != "" ]; then
               echo "! 已检测到dex文件，开始编译"
               if [[ "$(unzip -l /system/priv-app/"$e"/"$e".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /system/priv-app/"$e"/"$e".apk | grep lib/arm64)" != "" ]]; then
                  apk_abi=arm64
                  echo "- 该应用为64位应用"
               else
                  apk_abi=arm
                  echo "- 该应用为32位应用"
               fi
               mkdir -p "$MODPATH"/system/priv-app/"$e"/oat/"$apk_abi"
               echo "- 开始处理$e"
               dex2oat --dex-file=/system/priv-app/"$e"/"$e".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/priv-app/"$e"/oat/"$apk_abi"/"$e".odex
               echo "- 已完成对$e的odex分离处理"
               ((success_count++))
            else
               echo "! 未检测到dex文件，跳过编译"
               ((failed_count++))
               echo "/system/priv-app/$e/$e.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
            fi
         else
            echo "! 编译$e失败，没有apk文件"
            echo "/system/priv-app/$e/$e.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
            ((failed_count++))
         fi
      done
      if [ "$is_product" == 0 ]; then
         echo "- 开始处理/system/product/app"
         for f in $(ls -l /system/product/app | awk '/^d/ {print $NF}'); do
            if [ -f /system/product/app/"$f"/"$f".apk ]; then
               if [ "$(unzip -l /system/product/app/"$f"/"$f".apk | grep classes.dex)" != "" ]; then
                  echo "! 已检测到dex文件，开始编译"
                  if [[ "$(unzip -l /system/product/app/"$f"/"$f".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /system/product/app/"$f"/"$f".apk | grep lib/arm64)" != "" ]]; then
                     apk_abi=arm64
                     echo "- 该应用为64位应用"
                  else
                     apk_abi=arm
                     echo "- 该应用为32位应用"
                  fi
                  mkdir -p "$MODPATH"/system/product/app/"$f"/oat/"$apk_abi"
                  echo "- 开始处理$f"
                  dex2oat --dex-file=/system/product/app/"$f"/"$f".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/product/app/"$f"/oat/"$apk_abi"/"$f".odex
                  echo "- 已完成对$f的odex分离处理"
                  ((success_count++))
               else
                  echo "! 未检测到dex文件，跳过编译"
                  ((failed_count++))
                  echo "/system/product/app/$f/$f.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
               fi
            else
               echo "! 编译$f失败，没有apk文件"
               echo "/system/product/app/$f/$f.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
               ((failed_count++))
            fi
         done
         echo "- 开始处理/system/product/priv-app"
         for g in $(ls -l /system/product/priv-app | awk '/^d/ {print $NF}'); do
            if [ -f /system/product/priv-app/"$g"/"$g".apk ]; then
               if [ "$(unzip -l /system/product/priv-app/"$g"/"$g".apk | grep classes.dex)" != "" ]; then
                  echo "! 已检测到dex文件，开始编译"
                  if [[ "$(unzip -l /system/product/priv-app/"$g"/"$g".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /system/product/priv-app/"$g"/"$g".apk | grep lib/arm64)" != "" ]]; then
                     apk_abi=arm64
                     echo "- 该应用为64位应用"
                  else
                     apk_abi=arm
                     echo "- 该应用为32位应用"
                  fi
                  mkdir -p "$MODPATH"/system/product/priv-app/"$g"/oat/"$apk_abi"
                  echo "- 开始处理$g"
                  dex2oat --dex-file=/system/product/priv-app/"$g"/"$g".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/product/priv-app/"$g"/oat/"$apk_abi"/"$g".odex
                  echo "- 已完成对$g的odex分离处理"
                  ((success_count++))
               else
                  echo "! 未检测到dex文件，跳过编译"
                  ((failed_count++))
                  echo "/system/product/priv-app/$g/$g.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
               fi
            else
               echo "! 编译$g失败，没有apk文件"
               echo "/system/product/priv-app/$g/$g.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
               ((failed_count++))
            fi
         done
      fi
      if [ "$is_system_ext" == 0 ]; then
         echo "- 开始处理/system/system_ext/app"
         for h in $(ls -l /system/system_ext/app | awk '/^d/ {print $NF}'); do
            if [ -f /system/system_ext/app/"$h"/"$h".apk ]; then
               if [ "$(unzip -l /system/system_ext/app/"$h"/"$h".apk | grep classes.dex)" != "" ]; then
                  echo "! 已检测到dex文件，开始编译"
                  if [[ "$(unzip -l /system/system_ext/app/"$h"/"$h".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /system/system_ext/app/"$h"/"$h".apk | grep lib/arm64)" != "" ]]; then
                     apk_abi=arm64
                     echo "- 该应用为64位应用"
                  else
                     apk_abi=arm
                     echo "- 该应用为32位应用"
                  fi
                  mkdir -p "$MODPATH"/system/system_ext/app/"$h"/oat/"$apk_abi"
                  echo "- 开始处理$h"
                  dex2oat --dex-file=/system/system_ext/app/"$h"/"$h".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/system_ext/app/"$h"/oat/"$apk_abi"/"$h".odex
                  echo "- 已完成对$h的odex分离处理"
                  ((success_count++))
               else
                  echo "! 未检测到dex文件，跳过编译"
                  ((failed_count++))
                  echo "/system/system_ext/app/$h/$h.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
               fi
            else
               echo "! 解/oat/压$h失败，没有apk文件"
               echo "/system/system_ext/app/$h/$h.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
               ((failed_count++))
            fi
         done
         echo "- 开始处理/system/system_ext/priv-app"
         for i in $(ls -l /system/system_ext/priv-app | awk '/^d/ {print $NF}'); do
            if [ -f /system/system_ext/priv-app/"$i"/"$i".apk ]; then
               if [ "$(unzip -l /system/system_ext/priv-app/"$i"/"$i".apk | grep classes.dex)" != "" ]; then
                  echo "! 已检测到dex文件，开始编译"
                  if [[ "$(unzip -l /system/system_ext/priv-app/"$i"/"$i".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /system/system_ext/priv-app/"$i"/"$i".apk | grep lib/arm64)" != "" ]]; then
                     apk_abi=arm64
                     echo "- 该应用为64位应用"
                  else
                     apk_abi=arm
                     echo "- 该应用为32位应用"
                  fi
                  mkdir -p "$MODPATH"/system/system_ext/priv-app/"$i"/oat/"$apk_abi"
                  echo "- 开始处理$i"
                  dex2oat --dex-file=/system/system_ext/priv-app/"$i"/"$i".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/system_ext/priv-app/"$i"/oat/"$apk_abi"/"$i".odex
                  echo "- 已完成对$i的odex分离处理"
                  ((success_count++))
               else
                  echo "! 未检测到dex文件，跳过编译"
                  ((failed_count++))
                  echo "/system/system_ext/priv-app/$i/$i.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
               fi
            else
               echo "! 编译$i失败，没有apk文件"
               echo "/system/system_ext/priv-app/$i/$i.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
               ((failed_count++))
            fi
         done
      fi
      if [ "$is_vendor" == 0 ]; then
         echo "- 开始处理/system/vendor/app"
         for j in $(ls -l /system/vendor/app | awk '/^d/ {print $NF}'); do
            if [ -f /system/vendor/app/"$j"/"$j".apk ]; then
               if [ "$(unzip -l /system/vendor/app/"$j"/"$j".apk | grep classes.dex)" != "" ]; then
                  echo "! 已检测到dex文件，开始编译"
                  if [[ "$(unzip -l /system/vendor/app/"$j"/"$j".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /system/vendor/app/"$j"/"$j".apk | grep lib/arm64)" != "" ]]; then
                     apk_abi=arm64
                     echo "- 该应用为64位应用"
                  else
                     apk_abi=arm
                     echo "- 该应用为32位应用"
                  fi
                  mkdir -p "$MODPATH"/system/vendor/app/"$j"/oat/"$apk_abi"
                  echo "- 开始处理$j"
                  dex2oat --dex-file=/system/vendor/app/"$j"/"$j".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/vendor/app/"$j"/oat/"$apk_abi"/"$j".odex
                  echo "- 已完成对$j的odex分离处理"
                  ((success_count++))
               else
                  echo "! 未检测到dex文件，跳过编译"
                  ((failed_count++))
                  echo "/system/vendor/app/$j/$j.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
               fi
            else
               echo "! 编译$j失败，没有apk文件"
               echo "/system/vendor/app/$j/$j.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
               ((failed_count++))
            fi
         done
      fi
      echo "- 共$success_count次成功，$failed_count次失败，请检查$logfile中的日志"
   fi
   if [ $odex_module == true ]; then
      echo "- 正在制作模块，请坐和放宽"
      touch /data/adb/modules/miuiodex/module.prop
      {
         echo "id=miuiodex"
         echo "name=MIUI ODEX"
         echo "version=$version"
         echo "versionCode=$versionCode"
         echo "author=柚稚的孩纸&冷洛"
         echo "description=分离系统软件ODEX，MIUI$MIUI_version $modelversion Android$android_version，编译时间$time"
      } >>/data/adb/modules/miuiodex/module.prop
      for partition in vendor odm product system_ext; do
         [ -d $MODPATH/$partition ] && mv $MODPATH/$partition/* $MODPATH/system/$partition && rm -rf $MODPATH/$partition
      done
      find /data/adb/modules/miuiodex -type d -empty -delete >/dev/null
      echo "- 模块制作完成，请重启生效"
      sleep 5s
   else
      echo "- 未选择编译ODEX选项，不会生成模块"
   fi
else
   echo "- 不进行ODEX编译"
fi
if [[ "$dex2oat_mode" != null ]]; then
   find /data/app -name "base.apk" >/storage/emulated/0/Android/MIUI_odex/packages2.txt
   appnumber=0
   echo "- 正在统计待处理应用数量"
   for apk_path in $(cat /storage/emulated/0/Android/MIUI_odex/packages2.txt); do
      apk_dir="${apk_path%/*}"
      if [ "$(unzip -l "$apk_path" | grep classes.dex)" != "" ]; then
         ((apptotalnumber++))
      fi
   done
   echo "- 待处理应用数量：$apptotalnumber"
   for apk_path in $(cat $/storage/emulated/0/Android/MIUI_odex/packages2.txt); do
      apk_dir="${apk_path%/*}"
      record="$(eval cat /storage/emulated/0/Android/MIUI_odex/packages.txt | grep ^"$apk_path")"
      echo "- 开始处理${record##*=}"
      if [ "$(unzip -l "$apk_path" | grep classes.dex)" != "" ]; then
         echo "! 已检测到dex文件，开始编译"
         if [[ "$(unzip -l "$apk_path" | grep lib/)" == "" ]] || [[ "$(unzip -l "$apk_path" | grep lib/arm64)" != "" ]]; then
            apk_abi=arm64
            echo "- 该应用为64位应用"
         else
            apk_abi=arm
            echo "- 该应用为32位应用"
         fi
         rm -rf "$apk_dir"/oat/"$apk_abi"/*
         dex2oat --dex-file="$apk_path" --compiler-filter="$dex2oat_mode" --instruction-set="$apk_abi" --oat-file="$apk_dir"/oat/"$apk_abi"/base.odex
         echo "- 已完成对${record##*=}的应用优化"
         ((appnumber++))
      else
         echo "! 未检测到dex文件，跳过编译"
      fi
      percentage=$((appnumber * 100 / apptotalnumber))
      echo "已完成 $percentage%   $appnumber / $apptotalnumber"
   done
else
   echo "- 不进行Dex2oat编译"
fi
rm -rf /storage/emulated/0/Android/MIUI_odex/packages.txt
rm -rf /storage/emulated/0/Android/MIUI_odex/packages2.txt
