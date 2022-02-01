#!/bin/bash
# MIUI ODEX项目贡献者：柚稚的孩纸(zjw2017) & 雄氏老方(DavidPisces)
rm -rf $workfile
failed_count=0
logfile=/storage/emulated/0/MIUI_odex/log
MIUI_version_code=$(getprop ro.miui.ui.version.code)
MIUI_version_name=$(getprop ro.miui.ui.version.name)
modelversion="$(getprop ro.system.build.version.incremental)"
now_time=$(date '+%Y%m%d_%H:%M:%S')
SDK=$(getprop ro.system.build.version.sdk)
success_count=0
time=$(date "+%Y年%m月%d日%H:%M:%S")
workfile=/storage/emulated/0/MIUI_odex/system
if [ -d "/system/product" ]; then
   is_product=0
else
   is_product=1
fi
if [ -d "/system/product/app" ]; then
   mkdir -p $workfile/product/app
fi
if [ -d "/system/product/priv-app" ]; then
   mkdir -p $workfile/product/priv-app
fi
if [ -d "/system/product/framework" ]; then
   mkdir -p $workfile/product/framework
fi
if [ -d "/system/system_ext" ]; then
   is_system_ext=0
else
   is_system_ext=1
fi
if [ -d "/system/system_ext/app" ]; then
   mkdir -p $workfile/system_ext/app
fi
if [ -d "/system/system_ext/priv-app" ]; then
   mkdir -p $workfile/system_ext/priv-app
fi
if [ -d "/system/system_ext/framework" ]; then
   mkdir -p $workfile/system_ext/framework
fi
if [ -d "/system/vendor/app" ]; then
   mkdir -p $workfile/vendor/app
   is_vendor=0
else
   is_vendor=1
fi
if [ $SDK == 28 ]; then
   android_version=9
fi
if [ $SDK == 29 ]; then
   android_version=10
fi
if [ $SDK == 30 ]; then
   android_version=11
fi
if [ $SDK == 31 ]; then
   android_version=12
fi
if [[ $MIUI_version_code == 13 ]] && [[ $MIUI_version_name == V130 ]]; then
   MIUI_version=13
fi
if [[ $MIUI_version_code == 12 ]] && [[ $MIUI_version_name == V125 ]]; then
   MIUI_version=12.5 Enhanced
fi
if [[ $MIUI_version_code == 11 ]] && [[ $MIUI_version_name == V125 ]]; then
   MIUI_version=12.5
fi
if [[ $MIUI_version_code == 10 ]] && [[ $MIUI_version_name == V12 ]]; then
   MIUI_version=12
fi
if [[ $MIUI_version_code == 9 ]] && [[ $MIUI_version_name == V11 ]]; then
   MIUI_version=11
fi
if [ ! -f "/storage/emulated/0/MIUI_odex/version.prop" ]; then
   cd /storage/emulated/0/MIUI_odex
   curl -s -o version.prop https://gitee.com/yzdhz/odex-For-MIUI-WeeklyReleases/raw/master/update_online/version.prop
   if [ $? != 0 ]; then
      echo "- 请确保网络畅通"
      exit
   fi
fi
if [ ! -f "/storage/emulated/0/MIUI_odex/post-fs-data.sh" ]; then
   cd /storage/emulated/0/MIUI_odex
   curl -s -o version.prop https://gitee.com/yzdhz/odex-For-MIUI-WeeklyReleases/raw/master/update_online/post-fs-data.sh
   if [ $? != 0 ]; then
      echo "- 请确保网络畅通"
      exit
   fi
fi
source /storage/emulated/0/MIUI_odex/version.prop
mkdir -p /storage/emulated/0/MIUI_odex/log
mkdir -p $workfile/app
mkdir -p $workfile/priv-app
mkdir -p $workfile/framework
touch /storage/emulated/0/MIUI_odex/log/MIUI_odex_$now_time.log
clear
echo "*************************************************"
echo " "
echo " "
echo "                   MIUI ODEX"
echo "                   $version"
echo "                   本次更新日志：$description"
echo " "
echo " "
echo "*************************************************"
echo -e "\n- 请输入选项\n"
echo "[1] Simple (耗时较少,占用空间少，仅编译重要应用)"
echo "[2] Complete (耗时较长，占用空间大，完整编译)"
echo "[3] Skip ODEX (不进行ODEX编译)"
echo -e "\n请输入选项"
read choose_odex
clear
if [ $choose_odex == 3 ]; then
   echo "- 跳过odex编译，不会生成模块"
   odex_module=false
   echo "*************************************************"
   echo " "
   echo " "
   echo "                   MIUI ODEX"
   echo "                   $version"
   echo "                   本次更新日志：$description"
   echo " "
   echo "*************************************************"
   echo -e "\n- 您希望以什么模式进行Dex2oat\n"
   echo "[1] Speed (快速编译,耗时较短)"
   echo "[2] Everything (完整编译,耗时较长)"
   echo -e "\n请输入选项"
   read choose_dex2oat
else
   odex_module=true
   rm -rf /data/adb/modules/miuiodex
   echo "*************************************************"
   echo " "
   echo " "
   echo "                   MIUI ODEX"
   echo "                   $version"
   echo "                   本次更新日志：$description"
   echo " "
   echo "*************************************************"
   echo -e "\n- 您希望以什么模式进行Dex2oat\n"
   echo "[1] Speed (快速编译,耗时较短)"
   echo "[2] Everything (完整编译,耗时较长)"
   echo -e "\n请输入选项"
   read choose_dex2oat
   if [ $choose_odex == 1 ]; then
      echo "- 正在以Simple(简单)模式编译"
      cp -r /system/app/miui $workfile/app
      cp -r /system/app/miuisystem $workfile/app
      cp -r /system/app/XiaomiServiceFramework $workfile/app
      cp -r /system/priv-app/MiuiCamera $workfile/priv-app
      cp -r /system/priv-app/MiuiGallery $workfile/priv-app
      cp -r /system/priv-app/MiuiHome $workfile/priv-app
      cp -r /system/framework/*.jar $workfile/framework
      if [ $SDK -le 28 ]; then
         cp -r /system/priv-app/Settings $workfile/priv-app
         cp -r /system/priv-app/MiuiSystemUI $workfile/priv-app
      fi
      if [ $SDK == 29 ]; then
         cp -r /system/product/priv-app/Settings $workfile/product/priv-app
         cp -r /system/priv-app/MiuiSystemUI $workfile/priv-app
         cp -r /system/product/framework/*.jar $workfile/product/framework
         rm -rf $workfile/product/app
         rm -rf $workfile/system_ext
      fi
      if [[ $SDK == 30 ]] || [[ $SDK == 31 ]]; then
         cp -r /system/system_ext/priv-app/MiuiSystemUI $workfile/system_ext/priv-app
         cp -r /system/system_ext/priv-app/Settings $workfile/system_ext/priv-app
         cp -r /system/system_ext/framework/*.jar $workfile/system_ext/framework
         cp -r /system/product/framework/*.jar $workfile/product/framework
         rm -rf $workfile/product/app
         rm -rf $workfile/product/priv-app
         rm -rf $workfile/system_ext/app
      fi
      if [ $MIUI_version_name == V11 ]; then
         if [ -d "/system/priv-app/MiShare" ]; then
            cp -r /system/priv-app/MiShare $workfile/priv-app
         fi
         if [ -d "/system/priv-app/SecurityCenter" ]; then
            cp -r /system/priv-app/SecurityCenter $workfile/priv-app
         fi
      fi
      if [ $MIUI_version_name == V12 ]; then
         if [ -d "/system/priv-app/MiuiFreeformService" ]; then
            cp -r /system/priv-app/MiuiFreeformService $workfile/priv-app
         fi
         if [ -d "/system/priv-app/MiShare" ]; then
            cp -r /system/priv-app/MiShare $workfile/priv-app
         fi
         if [ -d "/system/priv-app/SecurityCenter" ]; then
            cp -r /system/priv-app/SecurityCenter $workfile/priv-app
         fi
      fi
      if [[ $MIUI_version_name == V125 ]] || [[ $MIUI_version_name == V130 ]]; then
         if [ -d "/system/priv-app/Mirror" ]; then
            cp -r /system/priv-app/Mirror $workfile/priv-app
         fi
         if [ -d "/system/priv-app/MiuiFreeformService" ]; then
            cp -r /system/priv-app/MiuiFreeformService $workfile/priv-app
         fi
         if [ -d "/system/priv-app/MiShare" ]; then
            cp -r /system/priv-app/MiShare $workfile/priv-app
         fi
         if [ -d "/system/priv-app/SecurityCenter" ]; then
            cp -r /system/priv-app/SecurityCenter $workfile/priv-app
         fi
      fi
      echo "- 文件复制完成，开始执行"
   else
      if [ $choose_odex == 2 ]; then
         echo "- 正在以Complete(完整)模式编译"
         cp -r /system/app/* $workfile/app
         cp -r /system/priv-app/* $workfile/priv-app
         cp -r /system/framework/*.jar $workfile/framework
         if [ $is_product == 0 ]; then
            cp -r /system/product/app/* $workfile/product/app
            cp -r /system/product/priv-app/* $workfile/product/priv-app
            cp -r /system/product/framework/*.jar $workfile/product/framework
         fi
         if [ $is_system_ext == 0 ]; then
            cp -r /system/system_ext/app/* $workfile/system_ext/app
            cp -r /system/system_ext/priv-app/* $workfile/system_ext/priv-app
            cp -r /system/system_ext/framework/*.jar $workfile/system_ext/framework
         fi
         if [ $is_vendor == 0 ]; then
            cp -r /system/vendor/app/* $workfile/vendor/app
         fi
         echo "- 文件复制完成，开始执行"
      fi
   fi
fi
clear
if [ $choose_odex != 3 ]; then
   # system部分
   echo "- 开始处理/system/framework"
   system_framework_jar=$(ls -l $workfile/framework | awk 'NR>1 {print $NF}')
   for a in $system_framework_jar; do
      cd $workfile/framework
      mkdir -p $workfile/framework/oat/arm
      mkdir -p $workfile/framework/oat/arm64
      oat32_1=$workfile/framework/oat/arm
      oat64_1=$workfile/framework/oat/arm64
      jarhead=$(basename $a .jar)
      echo "- 开始处理$a"
      dex2oat --dex-file=$workfile/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64_1/$jarhead.odex
      dex2oat --dex-file=$workfile/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32_1/$jarhead.odex
      rm -rf $workfile/framework/$jarhead.jar
      echo "- 已完成对$a的处理"
   done
   echo "- 开始处理/system/app"
   system_app=$(ls -l $workfile/app | awk '/^d/ {print $NF}')
   for d in $system_app; do
      cd $workfile/app/$d
      rm -rf $(find . ! -name '*.apk')
      unzip -q -o *.apk "classes.dex"
      if [ $? = 0 ]; then
         echo "- 解包$d成功，开始处理"
         if [ -f "classes.dex" ]; then
            echo "! 已检测到dex文件，开始编译"
            mkdir -p $workfile/app/$d/oat/arm64
            oat_1=$workfile/app/$d/oat/arm64
            dex2oat --dex-file=$workfile/app/$d/$d.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_1/$d.odex
            rm -rf $(find . -maxdepth 1 ! -name 'oat')
            echo "- 已完成对$d的odex分离处理"
            let success_count=success_count+1
         else
            echo "! 未检测到dex文件，跳过编译"
            rm -rf $workfile/app/$d
            let failed_count=failed_count+1
            echo "$d ：编译失败，没有dex文件" >>$logfile/MIUI_odex_$now_time.log
         fi
      else
         echo "! 解压$d失败，没有apk文件"
         rm -rf $workfile/app/$d
         echo "$d ：编译失败，没有apk文件" >>$logfile/MIUI_odex_$now_time.log
         let failed_count=failed_count+1
      fi
   done
   echo "- 开始处理/system/priv-app"
   system_priv_app=$(ls -l $workfile/priv-app | awk '/^d/ {print $NF}')
   for e in $system_priv_app; do
      cd $workfile/priv-app/$e
      rm -rf $(find . ! -name '*.apk')
      unzip -q -o *.apk "classes.dex"
      if [ $? = 0 ]; then
         echo "- 解包$e成功，开始处理"
         if [ -f "classes.dex" ]; then
            echo "! 已检测到dex文件，开始编译"
            mkdir -p $workfile/priv-app/$e/oat/arm64
            oat_2=$workfile/priv-app/$e/oat/arm64
            dex2oat --dex-file=$workfile/priv-app/$e/$e.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_2/$e.odex
            rm -rf $(find . -maxdepth 1 ! -name 'oat')
            echo "- 已完成对$e的odex分离处理"
            let success_count=success_count+1
         else
            echo "! 未检测到dex文件，跳过编译"
            rm -rf $workfile/priv-app/$e
            let failed_count=failed_count+1
            echo "$e ：编译失败，没有dex文件" >>$logfile/MIUI_odex_$now_time.log
         fi
      else
         echo "! 解压$e失败，没有apk文件"
         rm -rf $workfile/priv-app/$e
         echo "$e ：编译失败，没有apk文件" >>$logfile/MIUI_odex_$now_time.log
         let failed_count=failed_count+1
      fi
   done
   # product部分
   if [ $is_product == 0 ]; then
      echo "- 开始处理/system/product/framework"
      system_product_framework_jar=$(ls -l $workfile/product/framework | awk 'NR>1 {print $NF}')
      for b in $system_product_framework_jar; do
         cd $workfile/product/framework
         mkdir -p $workfile/product/framework/oat/arm
         mkdir -p $workfile/product/framework/oat/arm64
         oat32_2=$workfile/product/framework/oat/arm
         oat64_2=$workfile/product/framework/oat/arm64
         jarhead=$(basename $b .jar)
         echo "- 开始处理$b"
         dex2oat --dex-file=$workfile/product/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64_2/$jarhead.odex
         dex2oat --dex-file=$workfile/product/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32_2/$jarhead.odex
         rm -rf $workfile/product/framework/$jarhead.jar
         echo "- 已完成对$b的处理"
      done
      echo "- 开始处理/system/product/app"
      system_product_app=$(ls -l $workfile/product/app | awk '/^d/ {print $NF}')
      for f in $system_product_app; do
         cd $workfile/product/app/$f
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$f成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/product/app/$f/oat/arm64
               oat_3=$workfile/product/app/$f/oat/arm64
               dex2oat --dex-file=$workfile/product/app/$f/$f.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_3/$f.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- 已完成对$f的odex分离处理"
               let success_count=success_count+1
            else
               echo "! 未检测到dex文件，跳过编译"
               rm -rf $workfile/product/app/$f
               let failed_count=failed_count+1
               echo "$f ：编译失败，没有dex文件" >>$logfile/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$f失败，没有apk文件"
            rm -rf $workfile/product/app/$f
            echo "$f ：编译失败，没有apk文件" >>$logfile/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
      echo "- 开始处理/system/product/priv-app"
      system_product_priv_app=$(ls -l $workfile/product/priv-app | awk '/^d/ {print $NF}')
      for g in $system_product_priv_app; do
         cd $workfile/product/priv-app/$g
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$g成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/product/priv-app/$g/oat/arm64
               oat_4=$workfile/product/priv-app/$g/oat/arm64
               dex2oat --dex-file=$workfile/product/priv-app/$g/$g.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_4/$g.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- 已完成对$g的odex分离处理"
               let success_count=success_count+1
            else
               echo "! 未检测到dex文件，跳过编译"
               rm -rf $workfile/product/priv-app/$g
               let failed_count=failed_count+1
               echo "$g ：编译失败，没有dex文件" >>$logfile/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$g失败，没有apk文件"
            rm -rf $workfile/product/priv-app/$g
            echo "$g ：编译失败，没有apk文件" >>$logfile/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
   fi
   # system_ext部分
   if [ $is_system_ext == 0 ]; then
      echo "- 开始处理/system/system_ext/framework"
      system_ext_framework_jar=$(ls -l $workfile/system_ext/framework | awk 'NR>1 {print $NF}')
      for c in $system_ext_framework_jar; do
         cd $workfile/system_ext/framework
         mkdir -p $workfile/system_ext/framework/oat/arm
         mkdir -p $workfile/system_ext/framework/oat/arm64
         oat32_3=$workfile/system_ext/framework/oat/arm
         oat64_3=$workfile/system_ext/framework/oat/arm64
         jarhead=$(basename $c .jar)
         echo "- 开始处理$c"
         dex2oat --dex-file=$workfile/system_ext/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64_3/$jarhead.odex
         dex2oat --dex-file=$workfile/system_ext/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32_3/$jarhead.odex
         rm -rf $workfile/system_ext/framework/$jarhead.jar
         echo "- 已完成对$c的处理"
      done
      echo "- 开始处理/system/system_ext/app"
      system_system_ext_app=$(ls -l $workfile/system_ext/app | awk '/^d/ {print $NF}')
      for h in $system_system_ext_app; do
         cd $workfile/system_ext/app/$h
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$h成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/system_ext/app/$h/oat/arm64
               oat_5=$workfile/system_ext/app/$h/oat/arm64
               dex2oat --dex-file=$workfile/system_ext/app/$h/$h.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_5/$h.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- 已完成对$h的odex分离处理"
               let success_count=success_count+1
            else
               echo "! 未检测到dex文件，跳过编译"
               rm -rf $workfile/system_ext/app/$h
               let failed_count=failed_count+1
               echo "$h ：编译失败，没有dex文件" >>$logfile/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$h失败，没有apk文件"
            rm -rf $workfile/system_ext/app/$h
            echo "$h ：编译失败，没有apk文件" >>$logfile/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
      echo "- 开始处理/system/system_ext/priv-app"
      system_system_ext_priv_app=$(ls -l $workfile/system_ext/priv-app | awk '/^d/ {print $NF}')
      for i in $system_system_ext_priv_app; do
         cd $workfile/system_ext/priv-app/$i
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$i成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/system_ext/priv-app/$i/oat/arm64
               oat_6=$workfile/system_ext/priv-app/$i/oat/arm64
               dex2oat --dex-file=$workfile/system_ext/priv-app/$i/$i.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_6/$i.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- 已完成对$i的odex分离处理"
               let success_count=success_count+1
            else
               echo "! 未检测到dex文件，跳过编译"
               rm -rf $workfile/system_ext/priv-app/$i
               let failed_count=failed_count+1
               echo "$i ：编译失败，没有dex文件" >>$logfile/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$i失败，没有apk文件"
            rm -rf $workfile/system_ext/priv-app/$i
            echo "$i ：编译失败，没有apk文件" >>$logfile/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
   fi
   # vendor部分
   if [ $is_vendor == 0 ]; then
      echo "- 开始处理/system/vendor/app"
      system_vendor_app=$(ls -l $workfile/vendor/app | awk '/^d/ {print $NF}')
      for j in $system_vendor_app; do
         cd $workfile/vendor/app/$j
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$j成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/vendor/app/$j/oat/arm64
               oat_7=$workfile/vendor/app/$j/oat/arm64
               dex2oat --dex-file=$workfile/vendor/app/$j/$j.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_7/$j.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- 已完成对$j的odex分离处理"
               let success_count=success_count+1
            else
               echo "! 未检测到dex文件，跳过编译"
               rm -rf $workfile/vendor/app/$j
               let failed_count=failed_count+1
               echo "$j ：编译失败，没有dex文件" >>$logfile/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$j失败，没有apk文件"
            rm -rf $workfile/vendor/app/$j
            echo "$j ：编译失败，没有apk文件" >>$logfile/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
   fi
   echo "- 共$success_count次成功，$failed_count次失败，请检查$logfile中的日志"
   if [ $odex_module == true ]; then
      echo "- 正在制作模块，请坐和放宽"
      mkdir -p /data/adb/modules/miuiodex/system
      touch /data/adb/modules/miuiodex/module.prop
      touch /data/adb/modules/miuiodex/now_version
      touch /data/adb/modules/miuiodex/post-fs-data.sh
      echo "id=miuiodex" >>/data/adb/modules/miuiodex/module.prop
      echo "name=MIUI ODEX" >>/data/adb/modules/miuiodex/module.prop
      echo "version=$version" >>/data/adb/modules/miuiodex/module.prop
      echo "versionCode=$versionCode" >>/data/adb/modules/miuiodex/module.prop
      echo "author=柚稚的孩纸&雄式老方" >>/data/adb/modules/miuiodex/module.prop
      echo "description=分离系统软件ODEX，MIUI$MIUI_version $modelversion Android$android_version，编译时间$time" >>/data/adb/modules/miuiodex/module.prop
      echo "minMagisk=24000" >>/data/adb/modules/miuiodex/module.prop
      echo -n "updateJson=https://gitee.com/yzdhz/odex-For-MIUI-WeeklyReleases/raw/master/odex.json" >>/data/adb/modules/miuiodex/module.prop
      mv $workfile/* /data/adb/modules/miuiodex/system
      if [ $? = 0 ]; then
         echo "- 模块制作完成，请重启生效"
      else
         echo "! 模块制作失败"
      fi
   else
      echo "- 未选择编译odex选项，不会生成模块"
   fi
fi
if [ $choose_odex == 3 ]; then
   echo "- 不进行ODEX编译"
   mkdir -p $workfile/packagelist
   touch $workfile/packagelist/packagelist.log
   echo "$(pm list packages -3)" >$workfile/packagelist/packagelist.log
   if [ $choose_dex2oat == 1 ]; then
      apptotalnumber="$(grep -o "package:" $workfile/packagelist/packagelist.log | wc -l)"
      appnumber=0
      echo "正在以Speed模式优化用户软件"
      for item in $(pm list packages -3); do
         app=${item:8}
         echo "正在优化 -> $app"
         cmd package compile -m speed $app
         echo "应用优化完成"
         let appnumber=appnumber+1
         percentage=$((appnumber * 100 / apptotalnumber))
         echo "已完成 $percentage%   $appnumber / $apptotalnumber"
      done
   else
      if [ $choose_dex2oat == 2 ]; then
         apptotalnumber="$(grep -o "package:" $workfile/packagelist/packagelist.log | wc -l)"
         appnumber=0
         echo "正在以Everything模式优化用户软件"
         for item in $(pm list packages -3); do
            app=${item:8}
            echo "正在优化 -> $app"
            cmd package compile -m everything $app
            echo "应用优化完成"
            let appnumber=appnumber+1
            percentage=$((appnumber * 100 / apptotalnumber))
            echo "已完成 $percentage%   $appnumber / $apptotalnumber"
         done
      fi
   fi
else
   mkdir -p $workfile/packagelist
   touch $workfile/packagelist/packagelist.log
   echo "$(pm list packages -3)" >$workfile/packagelist/packagelist.log
   if [ $choose_dex2oat == 1 ]; then
      apptotalnumber="$(grep -o "package:" $workfile/packagelist/packagelist.log | wc -l)"
      appnumber=0
      echo "正在以Speed模式优化用户软件"
      for item in $(pm list packages -3); do
         app=${item:8}
         echo "正在优化 -> $app"
         cmd package compile -m speed $app
         echo "应用优化完成"
         let appnumber=appnumber+1
         percentage=$((appnumber * 100 / apptotalnumber))
         echo "已完成 $percentage%   $appnumber / $apptotalnumber"
      done
   else
      if [ $choose_dex2oat == 2 ]; then
         apptotalnumber="$(grep -o "package:" $workfile/packagelist/packagelist.log | wc -l)"
         appnumber=0
         echo "正在以Everything模式优化用户软件"
         for item in $(pm list packages -3); do
            app=${item:8}
            echo "正在优化 -> $app"
            cmd package compile -m everything $app
            echo "应用优化完成"
            let appnumber=appnumber+1
            percentage=$((appnumber * 100 / apptotalnumber))
            echo "已完成 $percentage%   $appnumber / $apptotalnumber"
         done
      fi
   fi
fi
rm -rf $workfile
echo "- 完成！"
