#!/bin/bash
# MIUI ODEX项目贡献者：柚稚的孩纸(zjw2017) & 冷洛(DavidPisces)
# 权限设置函数
set_perm() {
  chown "$2":"$3" "$1" || return 1
  chmod "$4" "$1" || return 1
  local CON="$5"
  [ -z "$CON" ] && CON=u:object_r:system_file:s0
  chcon "$CON" "$1" || return 1
}
set_perm_recursive() {
  find "$1" -type d 2>/dev/null | while read -r dir; do
    set_perm "$dir" "$2" "$3" "$4" "$6"
  done
  find "$1" -type f -o -type l 2>/dev/null | while read -r file; do
    set_perm "$file" "$2" "$3" "$5" "$6"
  done
}
# 环境检查
if [ "$(whoami)" != "root" ]; then
  echo "! 请使用Root运行脚本"
  exit
fi
[ ! -f /storage/emulated/0/Android/MIUI_odex/module.prop ] && echo "! 必备文件丢失，请重刷MIUI ODEX 脚本更新模块" && exit
[ ! -f /storage/emulated/0/Android/MIUI_odex/module_files/customize.sh ] && echo "! 必备文件丢失，请重刷MIUI ODEX 脚本更新模块" && exit
[ ! -f /storage/emulated/0/Android/MIUI_odex/module_files/uninstall.sh ] && echo "! 必备文件丢失，请重刷MIUI ODEX 脚本更新模块" && exit
[ ! -f /storage/emulated/0/Android/MIUI_odex/module_files/META-INF/com/google/android/update-binary ] && echo "! 必备文件丢失，请重刷MIUI ODEX 脚本更新模块" && exit
[ ! -f /storage/emulated/0/Android/MIUI_odex/module_files/META-INF/com/google/android/updater-script ] && echo "! 必备文件丢失，请重刷MIUI ODEX 脚本更新模块" && exit
logfile=/storage/emulated/0/Android/MIUI_odex/log
success_count=0
failed_count=0
MIUI_version_code=$(getprop ro.miui.ui.version.code)
MIUI_version_name=$(getprop ro.miui.ui.version.name)
MIUI_modelversion="$(getprop ro.system.build.version.incremental)"
HyperOS_version_code=$(getprop ro.mi.os.version.code)
HyperOS_version_name=$(getprop ro.mi.os.version.name)
HyperOS_modelversion="$(getprop ro.mi.os.version.incremental)"
if grep ksu_ /proc/kallsyms; then
  install_method=KSU
  MODPATH=/data/miuiodex
elif [ -f /data/adb/magisk/magisk64 ]; then
  install_method=MAGISK
  MODPATH=/data/adb/modules/miuiodex
fi
now_time=$(date '+%Y-%m-%d_%H:%M:%S')
SDK=$(getprop ro.system.build.version.sdk)
time=$(date "+%Y年%m月%d日%H:%M:%S")
version=$(grep -w "version" /storage/emulated/0/Android/MIUI_odex/module.prop | cut -d '=' -f2)
versionCode=$(grep -w "versionCode" /storage/emulated/0/Android/MIUI_odex/module.prop | cut -d '=' -f2)
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
elif [[ $SDK == 34 ]]; then
  android_version=14
fi
if [ -z "$HyperOS_version_code" ]; then
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
else
  if [[ $HyperOS_version_code == 1 ]] && [[ $HyperOS_version_name == "OS1.0" ]]; then
    HyperOS_version="1.0"
  fi
fi
mkdir -p $logfile
pm list packages -f -a | awk '!/overlay/' >/storage/emulated/0/Android/MIUI_odex/packages.txt
sed -i -e 's/\ /\\\n/g' -e 's/\\//g' -e 's/package://g' /storage/emulated/0/Android/MIUI_odex/packages.txt
sed -i '/^$/d' /storage/emulated/0/Android/MIUI_odex/packages.txt
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
  rm -rf "$MODPATH"
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
  mkdir -p "$MODPATH"/system/framework/oat/arm "$MODPATH"/system/framework/oat/arm64
  for a in /system/framework/*.jar; do
    a=${a##*/}
    jarhead=${a%.*}
    echo "- 开始处理$a"
    dex2oat --dex-file=/system/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm64 --oat-file="$MODPATH"/system/framework/oat/arm64/"$jarhead".odex
    dex2oat --dex-file=/system/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm --oat-file="$MODPATH"/system/framework/oat/arm/"$jarhead".odex
    echo "- 已完成对$a的处理"
  done
  if [ -d /product/framework ]; then
    echo "- 开始处理/product/framework"
    mkdir -p "$MODPATH"/system/product/framework/oat/arm "$MODPATH"/system/product/framework/oat/arm64
    for b in /product/framework/*.jar; do
      b=${b##*/}
      jarhead=${b%.*}
      echo "- 开始处理$b"
      dex2oat --dex-file=/product/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm64 --oat-file="$MODPATH"/system/product/framework/oat/arm64/"$jarhead".odex
      dex2oat --dex-file=/product/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm --oat-file="$MODPATH"/system/product/framework/oat/arm/"$jarhead".odex
      echo "- 已完成对$b的处理"
    done
  fi
  if [ -d /system_ext/framework ]; then
    echo "- 开始处理/system_ext/framework"
    mkdir -p "$MODPATH"/system/system_ext/framework/oat/arm "$MODPATH"/system/system_ext/framework/oat/arm64
    for c in /system_ext/framework/*.jar; do
      c=${c##*/}
      jarhead=${c%.*}
      echo "- 开始处理$c"
      dex2oat --dex-file=/system_ext/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm64 --oat-file="$MODPATH"/system/system_ext/framework/oat/arm64/"$jarhead".odex
      dex2oat --dex-file=/system_ext/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm --oat-file="$MODPATH"/system/system_ext/framework/oat/arm/"$jarhead".odex
      echo "- 已完成对$c的处理"
    done
  fi
  if [ -d /vendor/framework ]; then
    echo "- 开始处理/vendor/framework"
    mkdir -p "$MODPATH"/system/vendor/framework/oat/arm "$MODPATH"/system/vendor/framework/oat/arm64
    for l in /vendor/framework/*.jar; do
      l=${l##*/}
      jarhead=${l%.*}
      echo "- 开始处理$l"
      dex2oat --dex-file=/vendor/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm64 --oat-file="$MODPATH"/system/vendor/framework/oat/arm64/"$jarhead".odex
      dex2oat --dex-file=/vendor/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm --oat-file="$MODPATH"/system/vendor/framework/oat/arm/"$jarhead".odex
      echo "- 已完成对$l的处理"
    done
  fi
  if [[ "$choose_odex" == 1 ]]; then
    echo "- 正在以Simple(简单)模式编译"
    grep -v "#" /storage/emulated/0/Android/MIUI_odex/Simple_List.prop >/storage/emulated/0/Android/MIUI_odex/packages2.txt
    sed -i '/^$/d' /storage/emulated/0/Android/MIUI_odex/packages2.txt
    while IFS= read -r app_list; do
      var=$app_list
      record="$(eval cat /storage/emulated/0/Android/MIUI_odex/packages.txt | grep "$var"$)"
      apk_path="${record%=*}"
      apk_dir="${apk_path%/*}"
      apk_name="${apk_path##*/}"
      apk_name="${apk_name%.*}"
      apk_source="$(echo "$apk_dir" | cut -d"/" -f2)"
      if [ -n "$record" ]; then
        echo "- 开始处理$app_list"
        if [[ "$(unzip -l "$apk_path" | grep lib/)" == "" ]] || [[ "$(unzip -l "$apk_path" | grep lib/arm64)" != "" ]]; then
          apk_abi=arm64
          echo "- 该应用为64位应用"
        else
          apk_abi=arm
          echo "- 该应用为32位应用"
        fi
        if [ "$(unzip -l "$apk_path" | grep classes.dex)" != "" ]; then
          if [[ "$apk_source" == "data" ]]; then
            rm -rf "$apk_dir"/oat/"$apk_abi"/*
            dex2oat --dex-file="$apk_path" --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$apk_dir"/oat/"$apk_abi"/base.odex
            echo "- 已完成对$app_list的odex分离处理"
          else
            mkdir -p "$MODPATH""$apk_dir"/oat/"$apk_abi"
            dex2oat --dex-file="$apk_path" --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH""$apk_dir"/oat/"$apk_abi"/"$apk_name".odex
            echo "- 已完成对$app_list的odex分离处理"
          fi
        fi
        ((success_count++))
      else
        echo "! 编译$app_list失败，没有apk文件"
        echo "$app_list ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
        ((failed_count++))
      fi
    done </storage/emulated/0/Android/MIUI_odex/packages2.txt
  elif [[ "$choose_odex" == 2 ]]; then
    echo "- 开始处理/system/app"
    for d in /system/app/*; do
      d=${d##*/}
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
    for e in /system/priv-app/*; do
      e=${e##*/}
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
    if [ -d "/product/app" ]; then
      echo "- 开始处理/product/app"
      for f in /product/app/*; do
        f=${f##*/}
        if [ -f /product/app/"$f"/"$f".apk ]; then
          if [ "$(unzip -l /product/app/"$f"/"$f".apk | grep classes.dex)" != "" ]; then
            echo "! 已检测到dex文件，开始编译"
            if [[ "$(unzip -l /product/app/"$f"/"$f".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /product/app/"$f"/"$f".apk | grep lib/arm64)" != "" ]]; then
              apk_abi=arm64
              echo "- 该应用为64位应用"
            else
              apk_abi=arm
              echo "- 该应用为32位应用"
            fi
            mkdir -p "$MODPATH"/system/product/app/"$f"/oat/"$apk_abi"
            echo "- 开始处理$f"
            dex2oat --dex-file=/product/app/"$f"/"$f".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/product/app/"$f"/oat/"$apk_abi"/"$f".odex
            echo "- 已完成对$f的odex分离处理"
            ((success_count++))
          else
            echo "! 未检测到dex文件，跳过编译"
            ((failed_count++))
            echo "/product/app/$f/$f.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
          fi
        else
          echo "! 编译$f失败，没有apk文件"
          echo "/product/app/$f/$f.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
          ((failed_count++))
        fi
      done
      echo "- 开始处理/product/priv-app"
      for g in /product/priv-app/*; do
        g=${g##*/}
        if [ -f /product/priv-app/"$g"/"$g".apk ]; then
          if [ "$(unzip -l /product/priv-app/"$g"/"$g".apk | grep classes.dex)" != "" ]; then
            echo "! 已检测到dex文件，开始编译"
            if [[ "$(unzip -l /product/priv-app/"$g"/"$g".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /product/priv-app/"$g"/"$g".apk | grep lib/arm64)" != "" ]]; then
              apk_abi=arm64
              echo "- 该应用为64位应用"
            else
              apk_abi=arm
              echo "- 该应用为32位应用"
            fi
            mkdir -p "$MODPATH"/system/product/priv-app/"$g"/oat/"$apk_abi"
            echo "- 开始处理$g"
            dex2oat --dex-file=/product/priv-app/"$g"/"$g".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/product/priv-app/"$g"/oat/"$apk_abi"/"$g".odex
            echo "- 已完成对$g的odex分离处理"
            ((success_count++))
          else
            echo "! 未检测到dex文件，跳过编译"
            ((failed_count++))
            echo "/product/priv-app/$g/$g.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
          fi
        else
          echo "! 编译$g失败，没有apk文件"
          echo "/product/priv-app/$g/$g.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
          ((failed_count++))
        fi
      done
    fi
    if [ -d "/system_ext/app" ]; then
      echo "- 开始处理/system_ext/app"
      for h in /system_ext/app/*; do
        h=${h##*/}
        if [ -f /system_ext/app/"$h"/"$h".apk ]; then
          if [ "$(unzip -l /system_ext/app/"$h"/"$h".apk | grep classes.dex)" != "" ]; then
            echo "! 已检测到dex文件，开始编译"
            if [[ "$(unzip -l /system_ext/app/"$h"/"$h".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /system_ext/app/"$h"/"$h".apk | grep lib/arm64)" != "" ]]; then
              apk_abi=arm64
              echo "- 该应用为64位应用"
            else
              apk_abi=arm
              echo "- 该应用为32位应用"
            fi
            mkdir -p "$MODPATH"/system/system_ext/app/"$h"/oat/"$apk_abi"
            echo "- 开始处理$h"
            dex2oat --dex-file=/system_ext/app/"$h"/"$h".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/system_ext/app/"$h"/oat/"$apk_abi"/"$h".odex
            echo "- 已完成对$h的odex分离处理"
            ((success_count++))
          else
            echo "! 未检测到dex文件，跳过编译"
            ((failed_count++))
            echo "/system_ext/app/$h/$h.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
          fi
        else
          echo "! 解/oat/压$h失败，没有apk文件"
          echo "/system_ext/app/$h/$h.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
          ((failed_count++))
        fi
      done
      echo "- 开始处理/system_ext/priv-app"
      for i in /system_ext/priv-app/*; do
        i=${i##*/}
        if [ -f /system_ext/priv-app/"$i"/"$i".apk ]; then
          if [ "$(unzip -l /system_ext/priv-app/"$i"/"$i".apk | grep classes.dex)" != "" ]; then
            echo "! 已检测到dex文件，开始编译"
            if [[ "$(unzip -l /system_ext/priv-app/"$i"/"$i".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /system_ext/priv-app/"$i"/"$i".apk | grep lib/arm64)" != "" ]]; then
              apk_abi=arm64
              echo "- 该应用为64位应用"
            else
              apk_abi=arm
              echo "- 该应用为32位应用"
            fi
            mkdir -p "$MODPATH"/system/system_ext/priv-app/"$i"/oat/"$apk_abi"
            echo "- 开始处理$i"
            dex2oat --dex-file=/system_ext/priv-app/"$i"/"$i".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/system_ext/priv-app/"$i"/oat/"$apk_abi"/"$i".odex
            echo "- 已完成对$i的odex分离处理"
            ((success_count++))
          else
            echo "! 未检测到dex文件，跳过编译"
            ((failed_count++))
            echo "/system_ext/priv-app/$i/$i.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
          fi
        else
          echo "! 编译$i失败，没有apk文件"
          echo "/system_ext/priv-app/$i/$i.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
          ((failed_count++))
        fi
      done
    fi
    if [ -d "/vendor/app" ]; then
      echo "- 开始处理/vendor/app"
      for j in /vendor/app/*; do
        j=${j##*/}
        if [ -f /vendor/app/"$j"/"$j".apk ]; then
          if [ "$(unzip -l /vendor/app/"$j"/"$j".apk | grep classes.dex)" != "" ]; then
            echo "! 已检测到dex文件，开始编译"
            if [[ "$(unzip -l /vendor/app/"$j"/"$j".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /vendor/app/"$j"/"$j".apk | grep lib/arm64)" != "" ]]; then
              apk_abi=arm64
              echo "- 该应用为64位应用"
            else
              apk_abi=arm
              echo "- 该应用为32位应用"
            fi
            mkdir -p "$MODPATH"/system/vendor/app/"$j"/oat/"$apk_abi"
            echo "- 开始处理$j"
            dex2oat --dex-file=/vendor/app/"$j"/"$j".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/vendor/app/"$j"/oat/"$apk_abi"/"$j".odex
            echo "- 已完成对$j的odex分离处理"
            ((success_count++))
          else
            echo "! 未检测到dex文件，跳过编译"
            ((failed_count++))
            echo "/vendor/app/$j/$j.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
          fi
        else
          echo "! 编译$j失败，没有apk文件"
          echo "/vendor/app/$j/$j.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
          ((failed_count++))
        fi
      done
    fi
    if [ -d "/odm/app" ]; then
      echo "- 开始处理/odm/app"
      for k in /odm/app/*; do
        k=${k##*/}
        if [ -f /odm/app/"$k"/"$k".apk ]; then
          if [ "$(unzip -l /odm/app/"$k"/"$k".apk | grep classes.dex)" != "" ]; then
            echo "! 已检测到dex文件，开始编译"
            if [[ "$(unzip -l /odm/app/"$k"/"$k".apk | grep lib/)" == "" ]] || [[ "$(unzip -l /odm/app/"$k"/"$k".apk | grep lib/arm64)" != "" ]]; then
              apk_abi=arm64
              echo "- 该应用为64位应用"
            else
              apk_abi=arm
              echo "- 该应用为32位应用"
            fi
            mkdir -p "$MODPATH"/system/vendor/odm/app/"$k"/oat/"$apk_abi"
            echo "- 开始处理$k"
            dex2oat --dex-file=/odm/app/"$k"/"$k".apk --compiler-filter=everything --instruction-set="$apk_abi" --oat-file="$MODPATH"/system/vendor/odm/app/"$k"/oat/"$apk_abi"/"$k".odex
            echo "- 已完成对$k的odex分离处理"
            ((success_count++))
          else
            echo "! 未检测到dex文件，跳过编译"
            ((failed_count++))
            echo "/odm/app/$k/$k.apk ：编译失败，没有dex文件" >>"$logfile"/MIUI_odex_"$now_time".log
          fi
        else
          echo "! 编译$k失败，没有apk文件"
          echo "/odm/app/$k/$k.apk ：编译失败，没有apk文件" >>"$logfile"/MIUI_odex_"$now_time".log
          ((failed_count++))
        fi
      done
    fi
  fi
  if [ $odex_module == true ]; then
    echo "- 共$success_count次成功，$failed_count次失败，请检查$logfile中的日志"
    echo "- 正在制作模块，请坐和放宽"
    if [ -z "$HyperOS_version_code" ]; then
      touch "$MODPATH"/module.prop
      {
        echo "id=miuiodex"
        echo "name=MIUI ODEX"
        echo "version=$version"
        echo "versionCode=$versionCode"
        echo "author=柚稚的孩纸&冷洛"
        echo "description=分离系统软件ODEX，MIUI$MIUI_version $MIUI_modelversion Android$android_version，编译时间$time"
      } >>"$MODPATH"/module.prop
    else
      touch "$MODPATH"/module.prop
      {
        echo "id=miuiodex"
        echo "name=MIUI ODEX"
        echo "version=$version"
        echo "versionCode=$versionCode"
        echo "author=柚稚的孩纸&冷洛"
        echo "description=分离系统软件ODEX，HyperOS$MIUI_version $HyperOS_modelversion Android$android_version，编译时间$time"
      } >>"$MODPATH"/module.prop
    fi
    for partition in vendor odm product system_ext; do
      if [ -d "$MODPATH"/$partition ]; then
        if [[ "$partition" == "odm" ]]; then
          mkdir -p "$MODPATH"/system/vendor/$partition
          mv "$MODPATH"/$partition/* "$MODPATH"/system/vendor/$partition
        else
          mkdir -p "$MODPATH"/system/$partition
          mv "$MODPATH"/$partition/* "$MODPATH"/system/$partition
        fi
        rm -rf "${MODPATH:?}"/"${partition:?}"
      fi
    done
    find "$MODPATH" -type d -empty -delete >/dev/null
    if [ "$install_method" == "KSU" ]; then
      mv "$MODPATH"/* /storage/emulated/0/Android/MIUI_odex/module_files
      7zz a /storage/emulated/0/Android/MIUI_odex/MIUI_odex-"$time".zip /storage/emulated/0/Android/MIUI_odex/module_files/* >/dev/null 2>&1
      echo "- 模块制作完成，路径：/storage/emulated/0/Android/MIUI_odex/MIUI_odex-$time.zip"
      rm -rf "$MODPATH" /storage/emulated/0/Android/MIUI_odex/module_files/system /storage/emulated/0/Android/MIUI_odex/module_files/module.prop
    else
      cp -f /storage/emulated/0/Android/MIUI_odex/module_files/uninstall.sh "$MODPATH"
      set_perm_recursive "$MODPATH" 0 0 0755 0644
      [ -d "$MODPATH"/system/vendor/app ] && set_perm_recursive "$MODPATH"/system/vendor/app 0 0 0755 0644 u:object_r:vendor_file:s0
      [ -d "$MODPATH"/system/vendor/odm/app ] && set_perm_recursive "$MODPATH"/system/vendor/odm/app 0 0 0755 0644 u:object_r:vendor_file:s0
      [ -d "$MODPATH"/system/vendor/framework ] && set_perm_recursive "$MODPATH"/system/vendor/framework 0 0 0755 0644 u:object_r:vendor_framework_file:s0
      echo "- 模块制作完成，请重启生效"
    fi
    sleep 5s
  else
    echo "- 未选择编译ODEX选项，不会生成模块"
  fi
else
  echo "- 不进行ODEX编译"
fi
if [[ "$dex2oat_mode" != null ]]; then
  find /data/app -name "base.apk" >/storage/emulated/0/Android/MIUI_odex/packages3.txt
  sed -i '/^$/d' /storage/emulated/0/Android/MIUI_odex/packages3.txt
  appnumber=0
  echo "- 正在统计待处理应用数量"
  while IFS= read -r apk_path; do
    if [ "$(unzip -l "$apk_path" | grep classes.dex)" != "" ]; then
      ((apptotalnumber++))
    fi
  done </storage/emulated/0/Android/MIUI_odex/packages3.txt
  echo "- 待处理应用数量：$apptotalnumber"
  while IFS= read -r apk_path; do
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
  done </storage/emulated/0/Android/MIUI_odex/packages3.txt
else
  echo "- 不进行Dex2oat编译"
fi
rm -rf /storage/emulated/0/Android/MIUI_odex/packages.txt
rm -rf /storage/emulated/0/Android/MIUI_odex/packages2.txt
rm -rf /storage/emulated/0/Android/MIUI_odex/packages3.txt
