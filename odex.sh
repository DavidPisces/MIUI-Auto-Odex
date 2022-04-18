#!/bin/bash
# MIUI ODEX项目贡献者：柚稚的孩纸(zjw2017) & 冷洛(DavidPisces)
workfile=/storage/emulated/0/MIUI_odex/system
workfile_userapp=/storage/emulated/0/MIUI_odex/user-app
logfile=/storage/emulated/0/MIUI_odex/log
rm -rf $workfile $workfile_userapp
success_count=0
failed_count=0
appnumber_32=0
appnumber_64=0
MIUI_version_code=$(getprop ro.miui.ui.version.code)
MIUI_version_name=$(getprop ro.miui.ui.version.name)
modelversion="$(getprop ro.system.build.version.incremental)"
now_time=$(date '+%Y%m%d_%H:%M:%S')
SDK=$(getprop ro.system.build.version.sdk)
time=$(date "+%Y年%m月%d日%H:%M:%S")
version=$(cat /storage/emulated/0/MIUI_odex/odex.json | sed 's/,/\n/g' | grep -w "version" | sed 's/:/\n/g' | sed '1d' | sed 's/^[ ]*//g')
versionCode=$(cat /storage/emulated/0/MIUI_odex/odex.json | sed 's/,/\n/g' | grep -w "versionCode" | sed 's/:/\n/g' | sed '1d' | sed 's/^[ ]*//g')
if [[ $SDK == 28 ]]; then
   android_version=9
elif [[ $SDK == 29 ]]; then
   android_version=10
elif [[ $SDK == 30 ]]; then
   android_version=11
elif [[ $SDK == 31 ]]; then
   android_version=12
fi
if [[ $MIUI_version_code == 13 ]] && [[ $MIUI_version_name == V130 ]]; then
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
mkdir -p $workfile_userapp && echo "$(pm list package -f | grep -v verlay)" >"$workfile_userapp"/package.log
touch $logfile/MIUI_odex_"$now_time".log
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
   mkdir -p $workfile/app $workfile/priv-app $workfile/framework
   [ -d "/system/product/app" ] && mkdir -p $workfile/product/app && is_product=0
   [ -d "/system/product/priv-app" ] && mkdir -p $workfile/product/priv-app
   [ -d "/system/product/framework" ] && mkdir -p $workfile/product/framework && cp -r /system/product/framework/*.jar $workfile/product/framework
   [ -d "/system/system_ext/app" ] && mkdir -p $workfile/system_ext/app && is_system_ext=0
   [ -d "/system/system_ext/priv-app" ] && mkdir -p $workfile/system_ext/priv-app
   [ -d "/system/system_ext/framework" ] && mkdir -p $workfile/system_ext/framework && cp -r /system/system_ext/framework/*.jar $workfile/system_ext/framework
   [ -d "/system/vendor/app" ] && mkdir -p $workfile/vendor/app && is_vendor=0
   cp -r /system/framework/*.jar $workfile/framework
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
      dex2oat=speed
      ;;
   2)
      dex2oat=everything
      ;;
   3)
      dex2oat=null
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
      dex2oat=speed
      ;;
   2)
      dex2oat=everything
      ;;
   3)
      dex2oat=null
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
if [[ $choose_odex != 3 ]]; then
   if [[ $choose_odex == 1 ]]; then
      echo "- 正在以Simple(简单)模式编译"
      for line in $(cat /storage/emulated/0/MIUI_odex/Simple_List.prop | grep -v "#"); do
         for apk_line in $(grep "$line" "$workfile_userapp"/package.log | grep -v verlay); do
            for apk_path in ${apk_line#*:}; do
               apk_real_path=${apk_path%=*}
               if echo "$apk_real_path" | grep -q "/data"; then
                  echo "${apk_real_path%/*}" >>"$workfile_userapp"/apk外文件夹路径.txt
                  echo "$line" >>"$workfile_userapp"/已安装app的包名.txt
               else
                  if echo "${apk_real_path%/*}" | grep -q "/system/"; then
                     mkdir -p /storage/emulated/0/MIUI_odex"${apk_real_path%/*}" && cp -r "$apk_real_path" /storage/emulated/0/MIUI_odex"${apk_real_path%/*}"
                  else
                     mkdir -p "$workfile""${apk_real_path%/*}" && cp -r "$apk_real_path" "$workfile""${apk_real_path%/*}"
                  fi
               fi
            done
         done
      done
      echo "- 文件复制完成，开始执行"
   elif [[ $choose_odex == 2 ]]; then
      echo "- 正在以Complete(完整)模式编译"
      for system_app in $(ls -l /system/app | awk '/^d/ {print $NF}'); do
         [ -f /system/app/"$system_app"/"$system_app".apk ] && mkdir -p $workfile/app/"$system_app" && cp -r /system/app/"$system_app"/"$system_app".apk $workfile/app/"$system_app"
      done
      for system_priv_app in $(ls -l /system/priv-app | awk '/^d/ {print $NF}'); do
         [ -f /system/priv-app/"$system_priv_app"/"$system_priv_app".apk ] && mkdir -p $workfile/priv-app/"$system_priv_app" && cp -r /system/priv-app/"$system_priv_app"/"$system_priv_app".apk $workfile/priv-app/"$system_priv_app"
      done
      if [ $is_product == 0 ]; then
         for system_product_app in $(ls -l /system/product/app | awk '/^d/ {print $NF}'); do
            [ -f /system/product/app/"$system_product_app"/"$system_product_app".apk ] && mkdir -p $workfile/product/app/"$system_product_app" && cp -r /system/product/app/"$system_product_app"/"$system_product_app".apk $workfile/product/app/"$system_product_app"
         done
         for system_product_priv_app in $(ls -l /system/product/priv-app | awk '/^d/ {print $NF}'); do
            [ -f /system/product/priv-app/"$system_product_priv_app"/"$system_product_priv_app".apk ] && mkdir -p $workfile/product/priv-app/"$system_product_priv_app" && cp -r /system/product/priv-app/"$system_product_priv_app"/"$system_product_priv_app".apk $workfile/product/priv-app/"$system_product_priv_app"
         done
      fi
      if [ $is_system_ext == 0 ]; then
         for system_system_ext_app in $(ls -l /system/system_ext/app | awk '/^d/ {print $NF}'); do
            [ -f /system/system_ext/app/"$system_system_ext_app"/"$system_system_ext_app".apk ] && mkdir -p $workfile/system_ext/app/"$system_system_ext_app" && cp -r /system/system_ext/app/"$system_system_ext_app"/"$system_system_ext_app".apk $workfile/system_ext/app/"$system_system_ext_app"
         done
         for system_system_ext_priv_app in $(ls -l /system/system_ext/priv-app | awk '/^d/ {print $NF}'); do
            [ -f /system/system_ext/priv-app/"$system_system_ext_priv_app"/"$system_system_ext_priv_app".apk ] && mkdir -p $workfile/system_ext/priv-app/"$system_system_ext_priv_app" && cp -r /system/system_ext/priv-app/"$system_system_ext_priv_app"/"$system_system_ext_priv_app".apk $workfile/system_ext/priv-app/"$system_system_ext_priv_app"
         done
      fi
      if [ $is_vendor == 0 ]; then
         for system_vendor_app in $(ls -l /system/vendor/app | awk '/^d/ {print $NF}'); do
            [ -f /system/vendor/app/"$system_vendor_app"/"$system_vendor_app".apk ] && mkdir -p $workfile/vendor/app/"$system_vendor_app" && cp -r /system/vendor/app/"$system_vendor_app"/"$system_vendor_app".apk $workfile/vendor/app/"$system_vendor_app"
         done
      fi
      echo "- 文件复制完成，开始执行"
   fi
   # system部分
   echo "- 开始处理/system/framework"
   for a in $(ls -l $workfile/framework | awk 'NR>1 {print $NF}'); do
      mkdir -p $workfile/framework/oat/arm $workfile/framework/oat/arm64
      oat32=$workfile/framework/oat/arm
      oat64=$workfile/framework/oat/arm64
      jarhead=${a%.*}
      echo "- 开始处理$a"
      dex2oat --dex-file=$workfile/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64/"$jarhead".odex
      dex2oat --dex-file=$workfile/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32/"$jarhead".odex
      rm -rf $workfile/framework/"$jarhead".jar
      echo "- 已完成对$a的处理"
   done
   echo "- 开始处理/system/app"
   for b in $(ls -l $workfile/app | awk '/^d/ {print $NF}'); do
      cd $workfile/app/"$b" || exit
      if [ -f "$b".apk ]; then
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o "$b".apk "classes.dex"
         echo "- 解包$b成功，开始处理"
         if [ -f "classes.dex" ]; then
            echo "! 已检测到dex文件，开始编译"
            mkdir -p $workfile/app/"$b"/oat/arm64
            oat=$workfile/app/$b/oat/arm64
            dex2oat --dex-file=$workfile/app/"$b"/"$b".apk --compiler-filter=everything --instruction-set=arm64 --oat-file="$oat"/"$b".odex
            find . -maxdepth 1 ! -name 'oat' -exec rm {} \;
            echo "- 已完成对$b的odex分离处理"
            ((success_count++))
         else
            echo "! 未检测到dex文件，跳过编译"
            ((failed_count++))
            echo "/system/app/$b/$b.apk ：编译失败，没有dex文件" >>$logfile/MIUI_odex_"$now_time".log
         fi
      else
         echo "! 解压$b失败，没有apk文件"
         echo "/system/app/$b/$b.apk ：编译失败，没有apk文件" >>$logfile/MIUI_odex_"$now_time".log
         ((failed_count++))
      fi
   done
   echo "- 开始处理/system/priv-app"
   for c in $(ls -l $workfile/priv-app | awk '/^d/ {print $NF}'); do
      cd $workfile/priv-app/"$c" || exit
      if [ -f "$c".apk ]; then
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o "$c".apk "classes.dex"
         echo "- 解包$c成功，开始处理"
         if [ -f "classes.dex" ]; then
            echo "! 已检测到dex文件，开始编译"
            mkdir -p $workfile/priv-app/"$c"/oat/arm64
            oat=$workfile/priv-app/$c/oat/arm64
            dex2oat --dex-file=$workfile/priv-app/"$c"/"$c".apk --compiler-filter=everything --instruction-set=arm64 --oat-file="$oat"/"$c".odex
            find . -maxdepth 1 ! -name 'oat' -exec rm {} \;
            echo "- 已完成对$c的odex分离处理"
            ((success_count++))
         else
            echo "! 未检测到dex文件，跳过编译"
            ((failed_count++))
            echo "/system/priv-app/$c/$c.apk ：编译失败，没有dex文件" >>$logfile/MIUI_odex_"$now_time".log
         fi
      else
         echo "! 解压$c失败，没有apk文件"
         echo "/system/priv-app/$c/$c.apk ：编译失败，没有apk文件" >>$logfile/MIUI_odex_"$now_time".log
         ((failed_count++))
      fi
   done
   # product部分
   if [ $is_product == 0 ]; then
      echo "- 开始处理/system/product/framework"
      for d in $(ls -l $workfile/product/framework | awk 'NR>1 {print $NF}'); do
         mkdir -p $workfile/product/framework/oat/arm $workfile/product/framework/oat/arm64
         oat32=$workfile/product/framework/oat/arm
         oat64=$workfile/product/framework/oat/arm64
         jarhead=${d%.*}
         echo "- 开始处理$d"
         dex2oat --dex-file=$workfile/product/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64/"$jarhead".odex
         dex2oat --dex-file=$workfile/product/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32/"$jarhead".odex
         rm -rf $workfile/product/framework/"$jarhead".jar
         echo "- 已完成对$d的处理"
      done
      echo "- 开始处理/system/product/app"
      for e in $(ls -l $workfile/product/app | awk '/^d/ {print $NF}'); do
         cd $workfile/product/app/"$e" || exit
         if [ -f "$e".apk ]; then
            rm -rf $(find . ! -name '*.apk')
            unzip -q -o "$e".apk "classes.dex"
            echo "- 解包$e成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/product/app/"$e"/oat/arm64
               oat=$workfile/product/app/$e/oat/arm64
               dex2oat --dex-file=$workfile/product/app/"$e"/"$e".apk --compiler-filter=everything --instruction-set=arm64 --oat-file="$oat"/"$e".odex
               find . -maxdepth 1 ! -name 'oat' -exec rm {} \;
               echo "- 已完成对$e的odex分离处理"
               ((success_count++))
            else
               echo "! 未检测到dex文件，跳过编译"
               ((failed_count++))
               echo "/system/product/app/$e/$e.apk ：编译失败，没有dex文件" >>$logfile/MIUI_odex_"$now_time".log
            fi
         else
            echo "! 解压$e失败，没有apk文件"
            echo "/system/product/app/$e/$e.apk ：编译失败，没有apk文件" >>$logfile/MIUI_odex_"$now_time".log
            ((failed_count++))
         fi
      done
      echo "- 开始处理/system/product/priv-app"
      for f in $(ls -l $workfile/product/priv-app | awk '/^d/ {print $NF}'); do
         cd $workfile/product/priv-app/"$f" || exit
         if [ -f "$f".apk ]; then
            rm -rf $(find . ! -name '*.apk')
            unzip -q -o "$f".apk "classes.dex"
            echo "- 解包$f成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/product/priv-app/"$f"/oat/arm64
               oat=$workfile/product/priv-app/$f/oat/arm64
               dex2oat --dex-file=$workfile/product/priv-app/"$f"/"$f".apk --compiler-filter=everything --instruction-set=arm64 --oat-file="$oat"/"$f".odex
               find . -maxdepth 1 ! -name 'oat' -exec rm {} \;
               echo "- 已完成对$f的odex分离处理"
               ((success_count++))
            else
               echo "! 未检测到dex文件，跳过编译"
               ((failed_count++))
               echo "/system/product/priv-app/$f/$f.apk ：编译失败，没有dex文件" >>$logfile/MIUI_odex_"$now_time".log
            fi
         else
            echo "! 解压$f失败，没有apk文件"
            echo "/system/product/priv-app/$f/$f.apk ：编译失败，没有apk文件" >>$logfile/MIUI_odex_"$now_time".log
            ((failed_count++))
         fi
      done
   fi
   # system_ext部分
   if [ $is_system_ext == 0 ]; then
      echo "- 开始处理/system/system_ext/framework"
      for g in $(ls -l $workfile/system_ext/framework | awk 'NR>1 {print $NF}'); do
         mkdir -p $workfile/system_ext/framework/oat/arm $workfile/system_ext/framework/oat/arm64
         oat32=$workfile/system_ext/framework/oat/arm
         oat64=$workfile/system_ext/framework/oat/arm64
         jarhead=${g%.*}
         echo "- 开始处理$g"
         dex2oat --dex-file=$workfile/system_ext/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64/"$jarhead".odex
         dex2oat --dex-file=$workfile/system_ext/framework/"$jarhead".jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32/"$jarhead".odex
         rm -rf $workfile/system_ext/framework/"$jarhead".jar
         echo "- 已完成对$g的处理"
      done
      echo "- 开始处理/system/system_ext/app"
      for h in $(ls -l $workfile/system_ext/app | awk '/^d/ {print $NF}'); do
         cd $workfile/system_ext/app/"$h" || exit
         if [ -f "$h".apk ]; then
            rm -rf $(find . ! -name '*.apk')
            unzip -q -o "$h".apk "classes.dex"
            echo "- 解包$h成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/system_ext/app/"$h"/oat/arm64
               oat=$workfile/system_ext/app/$h/oat/arm64
               dex2oat --dex-file=$workfile/system_ext/app/"$h"/"$h".apk --compiler-filter=everything --instruction-set=arm64 --oat-file="$oat"/"$h".odex
               find . -maxdepth 1 ! -name 'oat' -exec rm {} \;
               echo "- 已完成对$h的odex分离处理"
               ((success_count++))
            else
               echo "! 未检测到dex文件，跳过编译"
               ((failed_count++))
               echo "/system/system_ext/app/$h/$h.apk ：编译失败，没有dex文件" >>$logfile/MIUI_odex_"$now_time".log
            fi
         else
            echo "! 解压$h失败，没有apk文件"
            echo "/system/system_ext/app/$h/$h.apk ：编译失败，没有apk文件" >>$logfile/MIUI_odex_"$now_time".log
            ((failed_count++))
         fi
      done
      echo "- 开始处理/system/system_ext/priv-app"
      for i in $(ls -l $workfile/system_ext/priv-app | awk '/^d/ {print $NF}'); do
         cd $workfile/system_ext/priv-app/"$i" || exit
         if [ -f "$i".apk ]; then
            rm -rf $(find . ! -name '*.apk')
            unzip -q -o "$i".apk "classes.dex"
            echo "- 解包$i成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/system_ext/priv-app/"$i"/oat/arm64
               oat=$workfile/system_ext/priv-app/$i/oat/arm64
               dex2oat --dex-file=$workfile/system_ext/priv-app/"$i"/"$i".apk --compiler-filter=everything --instruction-set=arm64 --oat-file="$oat"/"$i".odex
               find . -maxdepth 1 ! -name 'oat' -exec rm {} \;
               echo "- 已完成对$i的odex分离处理"
               ((success_count++))
            else
               echo "! 未检测到dex文件，跳过编译"
               ((failed_count++))
               echo "/system/system_ext/priv-app/$i/$i.apk ：编译失败，没有dex文件" >>$logfile/MIUI_odex_"$now_time".log
            fi
         else
            echo "! 解压$i失败，没有apk文件"
            echo "/system/system_ext/priv-app/$i/$i.apk ：编译失败，没有apk文件" >>$logfile/MIUI_odex_"$now_time".log
            ((failed_count++))
         fi
      done
   fi
   # vendor部分
   if [ $is_vendor == 0 ]; then
      echo "- 开始处理/system/vendor/app"
      for j in $(ls -l $workfile/vendor/app | awk '/^d/ {print $NF}'); do
         cd $workfile/vendor/app/"$j" || exit
         if [ -f "$j".apk ]; then
            rm -rf $(find . ! -name '*.apk')
            unzip -q -o "$j".apk "classes.dex"
            echo "- 解包$j成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/vendor/app/"$j"/oat/arm64
               oat=$workfile/vendor/app/$j/oat/arm64
               dex2oat --dex-file=$workfile/vendor/app/"$j"/"$j".apk --compiler-filter=everything --instruction-set=arm64 --oat-file="$oat"/"$j".odex
               find . -maxdepth 1 ! -name 'oat' -exec rm {} \;
               echo "- 已完成对$j的odex分离处理"
               ((success_count++))
            else
               echo "! 未检测到dex文件，跳过编译"
               ((failed_count++))
               echo "/system/vendor/app/$j/$j.apk ：编译失败，没有dex文件" >>$logfile/MIUI_odex_"$now_time".log
            fi
         else
            echo "! 解压$j失败，没有apk文件"
            echo "/system/vendor/app/$j/$j.apk ：编译失败，没有apk文件" >>$logfile/MIUI_odex_"$now_time".log
            ((failed_count++))
         fi
      done
   fi
   echo "- 共$success_count次成功，$failed_count次失败，请检查$logfile中的日志"
   if [ $odex_module == true ]; then
      echo "- 正在制作模块，请坐和放宽"
      mkdir -p /data/adb/modules/miuiodex/system
      touch /data/adb/modules/miuiodex/module.prop
      {
         echo "id=miuiodex"
         echo "name=MIUI ODEX"
         echo "version=$version"
         echo "versionCode=$versionCode"
         echo "author=柚稚的孩纸&冷洛"
         echo "description=分离系统软件ODEX，MIUI$MIUI_version $modelversion Android$android_version，编译时间$time"
         echo -n "minMagisk=24000"
      } >>/data/adb/modules/miuiodex/module.prop
      if mv $workfile/* /data/adb/modules/miuiodex/system; then
         find /data/adb/modules/miuiodex -type d -empty -delete >/dev/null
         echo "- 模块制作完成，请重启生效"
      else
         echo "! 模块制作失败"
      fi
   else
      echo "- 未选择编译ODEX选项，不会生成模块"
   fi
else
   echo "- 不进行ODEX编译"
fi
if [ "$choose_odex" == 1 ] && [ "$dex2oat" == null ]; then
   dex2oat=everything
   echo "- 正在以$dex2oat模式优化用户安装的软件"
   while IFS= read -r n; do
      dumpsys package "$n" | grep "arm: " >/dev/null && echo "$n" >>$workfile_userapp/32位app.txt
      dumpsys package "$n" | grep "arm64: " >/dev/null && echo "$n" >>$workfile_userapp/64位app.txt
   done <$workfile_userapp/已安装app的包名.txt
elif [ $dex2oat != null ]; then
   echo "- 正在以$dex2oat模式优化用户安装的软件"
   echo "- 百分比最终可能不为100％"
   rm -rf "$workfile_userapp"/apk外文件夹路径.txt
   rm -rf "$workfile_userapp"/已安装app的包名.txt
   find /data/app -name "base.apk" >$workfile_userapp/apk路径.txt
   while IFS= read -r k; do
      echo "${k%/*}" >>$workfile_userapp/apk外文件夹路径.txt
   done <$workfile_userapp/apk路径.txt
   while IFS= read -r l; do
      cat $workfile_userapp/package.log | grep "$l" >>$workfile_userapp/package2.log
   done <$workfile_userapp/apk路径.txt
   while IFS= read -r m; do
      echo "${m##*=}" >>$workfile_userapp/已安装app的包名.txt
   done <$workfile_userapp/package2.log
   while IFS= read -r n; do
      dumpsys package "$n" | grep "arm: " >/dev/null && echo "$n" >>$workfile_userapp/32位app.txt
      dumpsys package "$n" | grep "arm64: " >/dev/null && echo "$n" >>$workfile_userapp/64位app.txt
   done <$workfile_userapp/已安装app的包名.txt
   rm -rf $workfile_userapp/*.log
fi
if [ "$choose_odex" == 1 ] || [ "$dex2oat" != null ]; then
   if [ -f $workfile_userapp/32位app.txt ]; then
      apptotalnumber_32=$(sed -n '$=' $workfile_userapp/32位app.txt)
      echo "- 开始处理32位app"
      for o in $(cat $workfile_userapp/32位app.txt); do
         for p in $(cat $workfile_userapp/apk外文件夹路径.txt | grep -w "$o"); do
            cd "$p" || exit
            if unzip -q -o base.apk "classes.dex"; then
               echo "- 解包$o成功，开始处理"
               if [ -f "classes.dex" ]; then
                  echo "! 已检测到dex文件，开始编译"
                  rm -rf "$p"/oat/arm/*
                  oat=$p/oat/arm
                  dex2oat --dex-file="$p"/base.apk --compiler-filter=$dex2oat --instruction-set=arm --oat-file="$oat"/base.odex
                  rm -rf "$p"/classes.dex
                  echo "- 已完成对$o的应用优化"
                  ((appnumber_32++))
                  percentage_32=$((appnumber_32 * 100 / apptotalnumber_32))
                  echo "- 已完成 $percentage_32%   $appnumber_32 / $apptotalnumber_32"
               fi
            fi
         done
      done
   fi
   if [ -f $workfile_userapp/64位app.txt ]; then
      apptotalnumber_64=$(sed -n '$=' $workfile_userapp/64位app.txt)
      echo "- 开始处理64位app"
      for q in $(cat $workfile_userapp/64位app.txt); do
         for r in $(cat $workfile_userapp/apk外文件夹路径.txt | grep -w "$q"); do
            cd "$r" || exit
            if unzip -q -o base.apk "classes.dex"; then
               echo "- 解包$q成功，开始处理"
               if [ -f "classes.dex" ]; then
                  echo "! 已检测到dex文件，开始编译"
                  rm -rf "$r"/oat/arm64/*
                  oat=$r/oat/arm64
                  dex2oat --dex-file="$r"/base.apk --compiler-filter=$dex2oat --instruction-set=arm64 --oat-file="$oat"/base.odex
                  rm -rf "$r"/classes.dex
                  echo "- 已完成对$q的应用优化"
                  ((appnumber_64++))
                  percentage_64=$((appnumber_64 * 100 / apptotalnumber_64))
                  echo "- 已完成 $percentage_64%   $appnumber_64 / $apptotalnumber_64"
               fi
            fi
         done
      done
   fi
else
   echo "- 不进行Dex2oat编译"
fi
rm -rf $workfile $workfile_userapp
echo "- 完成！"
