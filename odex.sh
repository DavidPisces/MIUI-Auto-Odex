#!/bin/bash
# MIUI ODEX项目贡献者：柚稚的孩纸(zjw2017) & 冷洛(DavidPisces)
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
version=$(cat /storage/emulated/0/MIUI_odex/odex.json | sed 's/,/\n/g' | grep "version" | sed 's/:/\n/g' | sed '1d;3d;4d' | sed 's/^[ ]*//g')
versionCode=$(cat /storage/emulated/0/MIUI_odex/odex.json | sed 's/,/\n/g' | grep "versionCode" | sed 's/:/\n/g' | sed '1d' | sed 's/^[ ]*//g')
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
elif [ $SDK == 29 ]; then
   android_version=10
elif [ $SDK == 30 ]; then
   android_version=11
elif [ $SDK == 31 ]; then
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
echo "                      $version"
echo " "
echo " "
echo "*************************************************"
echo -e "\n- 请输入选项\n"
echo "[1] Simple (耗时较少,占用空间少，仅编译重要应用)"
echo "[2] Complete (耗时较长，占用空间大，完整编译)"
echo "[3] Skip ODEX (不进行ODEX编译)"
echo -e "\n请输入选项"
read choose_odex
case $choose_odex in
1 | 2)
   odex_module=true
   rm -rf /data/adb/modules/miuiodex
   clear
   echo "*************************************************"
   echo " "
   echo " "
   echo "                   MIUI ODEX"
   echo "                      $version"
   echo " "
   echo "*************************************************"
   echo -e "\n- 您希望以什么模式进行Dex2oat\n"
   echo "[1] Speed (快速编译,耗时较短)"
   echo "[2] Everything (完整编译,耗时较长)"
   echo "[3] Skip Dex2oat (不进行Dex2oat编译)"
   echo -e "\n请输入选项"
   read choose_dex2oat
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
   echo "                      $version"
   echo " "
   echo "*************************************************"
   echo -e "\n- 您希望以什么模式进行Dex2oat\n"
   echo "[1] Speed (快速编译,耗时较短)"
   echo "[2] Everything (完整编译,耗时较长)"
   echo "[3] Skip Dex2oat (不进行Dex2oat编译)"
   echo -e "\n请输入选项"
   read choose_dex2oat
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
if [ $choose_odex != 3 ]; then
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
   elif [ $choose_odex == 2 ]; then
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
   clear
   # system部分
   echo "- 开始处理/system/framework"
   for a in $(ls -l $workfile/framework | awk 'NR>1 {print $NF}'); do
      mkdir -p $workfile/framework/oat/arm
      mkdir -p $workfile/framework/oat/arm64
      oat32=$workfile/framework/oat/arm
      oat64=$workfile/framework/oat/arm64
      jarhead=$(basename $a .jar)
      echo "- 开始处理$a"
      dex2oat --dex-file=$workfile/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64/$jarhead.odex
      dex2oat --dex-file=$workfile/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32/$jarhead.odex
      rm -rf $workfile/framework/$jarhead.jar
      echo "- 已完成对$a的处理"
   done
   echo "- 开始处理/system/app"
   for b in $(ls -l $workfile/app | awk '/^d/ {print $NF}'); do
      cd $workfile/app/$b
      rm -rf $(find . ! -name '*.apk')
      unzip -q -o *.apk "classes.dex"
      if [ $? = 0 ]; then
         echo "- 解包$b成功，开始处理"
         if [ -f "classes.dex" ]; then
            echo "! 已检测到dex文件，开始编译"
            mkdir -p $workfile/app/$b/oat/arm64
            oat=$workfile/app/$b/oat/arm64
            dex2oat --dex-file=$workfile/app/$b/$b.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat/$b.odex
            rm -rf $(find . -maxdepth 1 ! -name 'oat')
            echo "- 已完成对$b的odex分离处理"
            let success_count=success_count+1
         else
            echo "! 未检测到dex文件，跳过编译"
            rm -rf $workfile/app/$b
            let failed_count=failed_count+1
            echo "$b ：编译失败，没有dex文件" >>$logfile/MIUI_odex_$now_time.log
         fi
      else
         echo "! 解压$b失败，没有apk文件"
         rm -rf $workfile/app/$b
         echo "$b ：编译失败，没有apk文件" >>$logfile/MIUI_odex_$now_time.log
         let failed_count=failed_count+1
      fi
   done
   echo "- 开始处理/system/priv-app"
   for c in $(ls -l $workfile/priv-app | awk '/^d/ {print $NF}'); do
      cd $workfile/priv-app/$c
      rm -rf $(find . ! -name '*.apk')
      unzip -q -o *.apk "classes.dex"
      if [ $? = 0 ]; then
         echo "- 解包$c成功，开始处理"
         if [ -f "classes.dex" ]; then
            echo "! 已检测到dex文件，开始编译"
            mkdir -p $workfile/priv-app/$c/oat/arm64
            oat=$workfile/priv-app/$c/oat/arm64
            dex2oat --dex-file=$workfile/priv-app/$c/$c.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat/$c.odex
            rm -rf $(find . -maxdepth 1 ! -name 'oat')
            echo "- 已完成对$c的odex分离处理"
            let success_count=success_count+1
         else
            echo "! 未检测到dex文件，跳过编译"
            rm -rf $workfile/priv-app/$c
            let failed_count=failed_count+1
            echo "$c ：编译失败，没有dex文件" >>$logfile/MIUI_odex_$now_time.log
         fi
      else
         echo "! 解压$c失败，没有apk文件"
         rm -rf $workfile/priv-app/$c
         echo "$c ：编译失败，没有apk文件" >>$logfile/MIUI_odex_$now_time.log
         let failed_count=failed_count+1
      fi
   done
   # product部分
   if [ $is_product == 0 ]; then
      echo "- 开始处理/system/product/framework"
      for d in $(ls -l $workfile/product/framework | awk 'NR>1 {print $NF}'); do
         mkdir -p $workfile/product/framework/oat/arm
         mkdir -p $workfile/product/framework/oat/arm64
         oat32=$workfile/product/framework/oat/arm
         oat64=$workfile/product/framework/oat/arm64
         jarhead=$(basename $d .jar)
         echo "- 开始处理$d"
         dex2oat --dex-file=$workfile/product/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64/$jarhead.odex
         dex2oat --dex-file=$workfile/product/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32/$jarhead.odex
         rm -rf $workfile/product/framework/$jarhead.jar
         echo "- 已完成对$d的处理"
      done
      echo "- 开始处理/system/product/app"
      for e in $(ls -l $workfile/product/app | awk '/^d/ {print $NF}'); do
         cd $workfile/product/app/$e
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$e成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/product/app/$e/oat/arm64
               oat=$workfile/product/app/$e/oat/arm64
               dex2oat --dex-file=$workfile/product/app/$e/$e.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat/$e.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- 已完成对$e的odex分离处理"
               let success_count=success_count+1
            else
               echo "! 未检测到dex文件，跳过编译"
               rm -rf $workfile/product/app/$e
               let failed_count=failed_count+1
               echo "$e ：编译失败，没有dex文件" >>$logfile/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$e失败，没有apk文件"
            rm -rf $workfile/product/app/$e
            echo "$e ：编译失败，没有apk文件" >>$logfile/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
      echo "- 开始处理/system/product/priv-app"
      for f in $(ls -l $workfile/product/priv-app | awk '/^d/ {print $NF}'); do
         cd $workfile/product/priv-app/$f
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$f成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/product/priv-app/$f/oat/arm64
               oat=$workfile/product/priv-app/$f/oat/arm64
               dex2oat --dex-file=$workfile/product/priv-app/$f/$f.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat/$f.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- 已完成对$f的odex分离处理"
               let success_count=success_count+1
            else
               echo "! 未检测到dex文件，跳过编译"
               rm -rf $workfile/product/priv-app/$f
               let failed_count=failed_count+1
               echo "$f ：编译失败，没有dex文件" >>$logfile/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$f失败，没有apk文件"
            rm -rf $workfile/product/priv-app/$f
            echo "$f ：编译失败，没有apk文件" >>$logfile/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
   fi
   # system_ext部分
   if [ $is_system_ext == 0 ]; then
      echo "- 开始处理/system/system_ext/framework"
      for g in $(ls -l $workfile/system_ext/framework | awk 'NR>1 {print $NF}'); do
         mkdir -p $workfile/system_ext/framework/oat/arm
         mkdir -p $workfile/system_ext/framework/oat/arm64
         oat32=$workfile/system_ext/framework/oat/arm
         oat64=$workfile/system_ext/framework/oat/arm64
         jarhead=$(basename $g .jar)
         echo "- 开始处理$g"
         dex2oat --dex-file=$workfile/system_ext/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64/$jarhead.odex
         dex2oat --dex-file=$workfile/system_ext/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32/$jarhead.odex
         rm -rf $workfile/system_ext/framework/$jarhead.jar
         echo "- 已完成对$g的处理"
      done
      echo "- 开始处理/system/system_ext/app"
      for h in $(ls -l $workfile/system_ext/app | awk '/^d/ {print $NF}'); do
         cd $workfile/system_ext/app/$h
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$h成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/system_ext/app/$h/oat/arm64
               oat=$workfile/system_ext/app/$h/oat/arm64
               dex2oat --dex-file=$workfile/system_ext/app/$h/$h.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat/$h.odex
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
      for i in $(ls -l $workfile/system_ext/priv-app | awk '/^d/ {print $NF}'); do
         cd $workfile/system_ext/priv-app/$i
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$i成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/system_ext/priv-app/$i/oat/arm64
               oat=$workfile/system_ext/priv-app/$i/oat/arm64
               dex2oat --dex-file=$workfile/system_ext/priv-app/$i/$i.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat/$i.odex
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
      for j in $(ls -l $workfile/vendor/app | awk '/^d/ {print $NF}'); do
         cd $workfile/vendor/app/$j
         rm -rf $(find . ! -name '*.apk')
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$j成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               mkdir -p $workfile/vendor/app/$j/oat/arm64
               oat=$workfile/vendor/app/$j/oat/arm64
               dex2oat --dex-file=$workfile/vendor/app/$j/$j.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat/$j.odex
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
      echo "id=miuiodex" >>/data/adb/modules/miuiodex/module.prop
      echo "name=MIUI ODEX" >>/data/adb/modules/miuiodex/module.prop
      echo "version=$version" >>/data/adb/modules/miuiodex/module.prop
      echo "versionCode=$versionCode" >>/data/adb/modules/miuiodex/module.prop
      echo "author=柚稚的孩纸&冷洛" >>/data/adb/modules/miuiodex/module.prop
      echo "description=分离系统软件ODEX，MIUI$MIUI_version $modelversion Android$android_version，编译时间$time" >>/data/adb/modules/miuiodex/module.prop
      echo -n "minMagisk=24000" >>/data/adb/modules/miuiodex/module.prop
      mv $workfile/* /data/adb/modules/miuiodex/system
      if [ $? = 0 ]; then
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
if [ $dex2oat != null ]; then
   echo "- 正在以$dex2oat模式优化用户软件"
   echo "- 百分比最终可能不为100％"
   appnumber_32=0
   appnumber_64=0
   mkdir -p $workfile/user-app
   find /data/app -name *.apk >$workfile/user-app/apk路径.txt
   for k in $(cat $workfile/user-app/apk路径.txt); do
      echo ${k%/*} >>$workfile/user-app/apk外文件夹路径.txt
   done
   echo "$(pm list package -f)" >$workfile/user-app/tmp1.log
   for l in $(cat $workfile/user-app/apk路径.txt); do
      echo "$(cat $workfile/user-app/tmp1.log | grep $l)" >>$workfile/user-app/tmp2.log
   done
   for m in $(cat $workfile/user-app/tmp2.log); do
      echo "${m##*=}" >>$workfile/user-app/已安装app的包名.txt
   done
   for n in $(cat $workfile/user-app/已安装app的包名.txt); do
      dumpsys package $n | grep "arm: " >/dev/null
      if [ $? == 0 ]; then
         echo "$n" >>$workfile/user-app/32位app.txt
      fi
      dumpsys package $n | grep "arm64: " >/dev/null
      if [ $? == 0 ]; then
         echo "$n" >>$workfile/user-app/64位app.txt
      fi
   done
   rm -rf $workfile/user-app/*.log
   apptotalnumber_32=$(sed -n '$=' $workfile/user-app/32位app.txt)
   echo "- 开始处理32位app"
   for o in $(cat $workfile/user-app/32位app.txt); do
      for p in $(cat $workfile/user-app/apk外文件夹路径.txt | grep $o); do
         cd $p
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$o成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               rm -rf $p/oat/arm
               mkdir -p $p/oat/arm
               oat=$p/oat/arm
               dex2oat --dex-file=$p/base.apk --compiler-filter=$dex2oat --instruction-set=arm --oat-file=$oat/base.odex
               rm -rf $p/classes.dex
               echo "- 已完成对$o的应用优化"
               let appnumber_32=appnumber_32+1
               percentage_32=$((appnumber_32 * 100 / apptotalnumber_32))
               echo "- 已完成 $percentage_32%   $appnumber_32 / $apptotalnumber_32"
            fi
         fi
      done
   done
   apptotalnumber_64=$(sed -n '$=' $workfile/user-app/64位app.txt)
   echo "- 开始处理64位app"
   for q in $(cat $workfile/user-app/64位app.txt); do
      for r in $(cat $workfile/user-app/apk外文件夹路径.txt | grep $q); do
         cd $r
         unzip -q -o *.apk "classes.dex"
         if [ $? = 0 ]; then
            echo "- 解包$q成功，开始处理"
            if [ -f "classes.dex" ]; then
               echo "! 已检测到dex文件，开始编译"
               rm -rf $r/oat/arm64
               mkdir -p $r/oat/arm64
               oat=$r/oat/arm64
               dex2oat --dex-file=$r/base.apk --compiler-filter=$dex2oat --instruction-set=arm64 --oat-file=$oat/base.odex
               rm -rf $r/classes.dex
               echo "- 已完成对$q的应用优化"
               let appnumber_64=appnumber_64+1
               percentage_64=$((appnumber_64 * 100 / apptotalnumber_64))
               echo "- 已完成 $percentage_64%   $appnumber_64 / $apptotalnumber_64"
            fi
         fi
      done
   done
else
   echo "- 不进行Dex2oat编译"
fi
rm -rf $workfile
echo "- 完成！"
