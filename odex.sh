#!/bin/bash
# MIUI ODEX项目贡献者：柚稚的孩纸(zjw2017) 雄氏老方(DavidPisces)
nowversion=6.3
workfile=/storage/emulated/0/MIUI_odex/system
success_count=0
failed_count=0
now_time=$(date '+%Y%m%d_%H:%M:%S')
echo "- Prepearing tools"
# rm
rm -rf $workfile
# create environment
echo "- Create necessary environment"
mkdir -p /storage/emulated/0/MIUI_odex/log
mkdir -p /storage/emulated/0/MIUI_odex/system/app
mkdir -p /storage/emulated/0/MIUI_odex/system/priv-app
mkdir -p /storage/emulated/0/MIUI_odex/system/framework
if [ -d "/system/product" ]; then
   is_product=0
else
   is_product=1
fi
if [ -d "/system/product/app" ]; then
   mkdir -p /storage/emulated/0/MIUI_odex/system/product/app
   is_product_app=0
else
   is_product_app=1
fi
if [ -d "/system/product/priv-app" ]; then
   mkdir -p /storage/emulated/0/MIUI_odex/system/product/priv-app
   is_product_priv_app=0
else
   is_product_priv_app=1
fi
if [ -d "/system/product/framework" ]; then
   mkdir -p /storage/emulated/0/MIUI_odex/system/product/framework
   is_product_framework=0
else
   is_product_framework=1
fi
if [ -d "/system/system_ext" ]; then
   is_system_ext=0
else
   is_system_ext=1
fi
if [ -d "/system/system_ext/app" ]; then
   mkdir -p /storage/emulated/0/MIUI_odex/system/system_ext/app
   is_system_ext_app=0
else
   is_system_ext_app=1
fi
if [ -d "/system/system_ext/priv-app" ]; then
   mkdir -p /storage/emulated/0/MIUI_odex/system/system_ext/priv-app
   is_system_ext_priv_app=0
else
   is_system_ext_priv_app=1
fi
if [ -d "/system/system_ext/framework" ]; then
   mkdir -p /storage/emulated/0/MIUI_odex/system/system_ext/framework
   is_system_ext_framework=0
else
   is_system_ext_framework=1
fi
if [ -d "/system/vendor/app" ]; then
   mkdir -p /storage/emulated/0/MIUI_odex/system/vendor/app
   is_vendor_app=0
else
   is_vendor_app=1
fi
# Get system SDK
SDK=$(getprop ro.system.build.version.sdk)
# Get MIUI Version
MIUI_version=$(getprop ro.miui.ui.version.name)
# create tool log
touch /storage/emulated/0/MIUI_odex/log/MIUI_odex_$now_time.log
# clean
clear
# core
echo "*************************************************"
echo " "
echo " "
echo "                   MIUI ODEX"
echo "                     $nowversion"
echo " "
echo " "
echo "*************************************************"
echo -e "\n- What mode do you want ODEX to be compiled\n"
echo "[1] Simple (less time and less space,only important system apps)"
echo "[2] Complete (all system apps will be compiled)"
echo "[3] Skip ODEX"
echo -e "\nPlease enter an option"
read choose_odex
clear
if [ $choose_odex == 3 ]; then
   echo "- Skip ODEX compilation and no Magisk modules will be created"
   odex_module=false
   # Choose Dex2oat mode
   echo "*************************************************"
   echo " "
   echo " "
   echo "                   MIUI ODEX"
   echo "                     $nowversion"
   echo " "
   echo "*************************************************"
   echo -e "\n- What mode do you want to run Dex2oat\n"
   echo "[1] Speed (Fast and less time)"
   echo "[2] Everything (Best performance but need more time)"
   echo -e "\nPlease enter an option"
   read choose_dex2oat
else
   # Delete the last compilation result
   rm -rf /data/adb/modules/miuiodex
   # Choose Dex2oat mode
   echo "*************************************************"
   echo " "
   echo " "
   echo "                   MIUI ODEX"
   echo "                     $nowversion"
   echo " "
   echo "*************************************************"
   echo -e "\n- What mode do you want to run Dex2oat\n"
   echo "[1] Speed (Fast and less time)"
   echo "[2] Everything (Best performance but need more time)"
   echo -e "\nPlease enter an option"
   read choose_dex2oat
   if [ $choose_odex == 1 ]; then
      echo "- Compiling in simple mode"
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
         rm -rf $workfile/product
         rm -rf $workfile/system_ext
      fi
      if [ $SDK == 29 ]; then
         cp -r /system/product/priv-app/Settings $workfile/product/priv-app
         cp -r /system/priv-app/MiuiSystemUI $workfile/priv-app
         cp -r /system/product/framework/*.jar $workfile/product/framework
         rm -rf $workfile/product/app
         rm -rf $workfile/system_ext
      fi
      if [ $SDK == 30 ]; then
         cp -r /system/system_ext/priv-app/MiuiSystemUI $workfile/system_ext/priv-app
         cp -r /system/system_ext/priv-app/Settings $workfile/system_ext/priv-app
         cp -r /system/system_ext/framework/*.jar $workfile/system_ext/framework
         cp -r /system/product/framework/*.jar $workfile/product/framework
         rm -rf $workfile/product/app
         rm -rf $workfile/product/priv-app
         rm -rf $workfile/system_ext/app
      fi
      if [ $MIUI_version = V11 ]; then
         cp -r /system/priv-app/MiShare $workfile/priv-app
         cp -r /system/priv-app/SecurityCenter $workfile/priv-app
      fi
      if [ $MIUI_version = V12 ]; then
         cp -r /system/priv-app/MiShare $workfile/priv-app
         cp -r /system/priv-app/MiuiFreeformService $workfile/priv-app
         cp -r /system/priv-app/SecurityCenter $workfile/priv-app
      fi
      if [ $MIUI_version = V125 ]; then
         cp -r /system/priv-app/Mirror $workfile/priv-app
         cp -r /system/priv-app/MiShare $workfile/priv-app
         cp -r /system/priv-app/MiuiFreeformService $workfile/priv-app
         cp -r /system/priv-app/MIUISecurityCenter $workfile/priv-app
      fi
      echo "- Apps copy completed,processing started"
      odex_module=true
   else
      if [ $choose_odex == 2 ]; then
         echo "- Compiling in simple mode"
         # 复制相关文件
         cp -r /system/app/* $workfile/app
         cp -r /system/priv-app/* $workfile/priv-app
         cp -r /system/framework/*.jar $workfile/framework
         if [ $is_product == 0 ]; then
            cp -r /system/product/app/* $workfile/product/app
            cp -r /system/product/priv-app/* $workfile/product/priv-app
            cp -r /system/product/framework/* $workfile/product/framework
         fi
         if [ $is_system_ext == 0 ]; then
            cp -r /system/system_ext/app/* $workfile/system_ext/app
            cp -r /system/system_ext/priv-app/* $workfile/system_ext/priv-app
            cp -r /system/system_ext/framework/* $workfile/system_ext/framework
         fi
         echo "- Apps copy completed,processing started"
         odex_module=true
      fi
   fi
fi
# clear
clear
if [ $choose_odex != 3 ]; then
   echo "- Starting process framework"
   # /system/framework
   system_framework_jar=$(ls -l $workfile/framework | awk 'NR>1 {print $NF}')
   for a in $system_framework_jar; do
      cd $workfile/framework
      mkdir -p $workfile/framework/oat/arm
      mkdir -p $workfile/framework/oat/arm64
      oat32_1=$workfile/framework/oat/arm
      oat64_1=$workfile/framework/oat/arm64
      jarhead=$(basename $a .jar)
      echo "- Processing $a"
      dex2oat --dex-file=$workfile/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64_1/$jarhead.odex
      dex2oat --dex-file=$workfile/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32_1/$jarhead.odex
      rm -rf $workfile/framework/$jarhead.jar
      echo "- Completed processing $a"
   done
   if [ $is_product == 0 ]; then
      # /system/product/framework
      system_product_framework_jar=$(ls -l $workfile/product/framework | awk 'NR>1 {print $NF}')
      for b in $system_product_framework_jar; do
         cd $workfile/product/framework
         mkdir -p $workfile/product/framework/oat/arm
         mkdir -p $workfile/product/framework/oat/arm64
         oat32_2=$workfile/product/framework/oat/arm
         oat64_2=$workfile/product/framework/oat/arm64
         jarhead=$(basename $b .jar)
         echo "- Processing $b"
         dex2oat --dex-file=$workfile/product/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64_2/$jarhead.odex
         dex2oat --dex-file=$workfile/product/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32_2/$jarhead.odex
         rm -rf $workfile/product/framework/$jarhead.jar
         echo "- Completed processing $b"
      done
   fi
   if [ $is_system_ext == 0 ]; then
      # /system/system_ext/framework
      system_ext_framework_jar=$(ls -l $workfile/system_ext/framework | awk 'NR>1 {print $NF}')
      for c in $system_ext_framework_jar; do
         cd $workfile/system_ext/framework
         mkdir -p $workfile/system_ext/framework/oat/arm
         mkdir -p $workfile/system_ext/framework/oat/arm64
         oat32_3=$workfile/system_ext/framework/oat/arm
         oat64_3=$workfile/system_ext/framework/oat/arm64
         jarhead=$(basename $c .jar)
         echo "- Processing $c"
         dex2oat --dex-file=$workfile/system_ext/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64_3/$jarhead.odex
         dex2oat --dex-file=$workfile/system_ext/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32_3/$jarhead.odex
         rm -rf $workfile/system_ext/framework/$jarhead.jar
         echo "- Completed processing $c"
      done
   fi
   echo "- Completed processing framework"
   # system/app
   system_app=$(ls -l $workfile/app | awk '/^d/ {print $NF}')
   for d in $system_app; do
      cd $workfile/app/$d
      rm -rf $(find . ! -name '*.apk')
      # unzip
      unzip -q -o *.apk "classes.dex"
      # Are APK decompressed successfully
      if [ $? = 0 ]; then
         echo "- Unzip $d successfully,processing"
         # Judge whether it exists classes.dex
         if [ -f "classes.dex" ]; then
            echo "! dex file detected,processing"
            mkdir -p $workfile/app/$d/oat/arm64
            oat_1=$workfile/app/$d/oat/arm64
            dex2oat --dex-file=$workfile/app/$d/$d.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_1/$d.odex
            rm -rf $(find . -maxdepth 1 ! -name 'oat')
            echo "- Process $d success"
            let success_count=success_count+1
         else
            echo "! dex file not detected,skip"
            rm -rf $workfile/app/$d
            let failed_count=failed_count+1
            echo "$d ：Process failed,dex file not detected" >>$workfile/log/MIUI_odex_$now_time.log
         fi
      else
         echo "! Faild to unzip $d,apk file does not exist"
         rm -rf $workfile/app/$d
         echo "$d ：Process failed,apk file not detected" >>$workfile/log/MIUI_odex_$now_time.log
         let failed_count=failed_count+1
      fi
   done
   # system/priv-app
   system_priv_app=$(ls -l $workfile/priv-app | awk '/^d/ {print $NF}')
   for e in $system_priv_app; do
      cd $workfile/priv-app/$e
      rm -rf $(find . ! -name '*.apk')
      # unzip 
      unzip -q -o *.apk "classes.dex"
      # Are APK decompressed successfully
      if [ $? = 0 ]; then
         echo "- Unzip $e successfully,processing"
         # Judge whether it exists classes.dex
         if [ -f "classes.dex" ]; then
            echo "! dex file detected,processing"
            mkdir -p $workfile/priv-app/$e/oat/arm64
            oat_2=$workfile/priv-app/$e/oat/arm64
            dex2oat --dex-file=$workfile/priv-app/$e/$e.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_2/$e.odex
            rm -rf $(find . -maxdepth 1 ! -name 'oat')
            echo "- Process $e success"
            let success_count=success_count+1
         else
            echo "! dex file not detected,skip"
            rm -rf $workfile/priv-app/$e
            let failed_count=failed_count+1
            echo "$e ：Process failed,dex file not detected" >>$workfile/log/MIUI_odex_$now_time.log
         fi
      else
         echo "! Faild to unzip $e,apk file does not exist"
         rm -rf $workfile/priv-app/$e
         echo "$e ：Process failed,apk file not detected" >>$workfile/log/MIUI_odex_$now_time.log
         let failed_count=failed_count+1
      fi
   done
   if [ $is_product == 0 ]; then
      # system/product/app
      system_product_app=$(ls -l $workfile/product/app | awk '/^d/ {print $NF}')
      for f in $system_product_app; do
         cd $workfile/product/app/$f
         rm -rf $(find . ! -name '*.apk')
         # unzip
         unzip -q -o *.apk "classes.dex"
         # Are APK decompressed successfully
         if [ $? = 0 ]; then
            echo "- Unzip $f successfully,processing"
            # Judge whether it exists classes.dex
            if [ -f "classes.dex" ]; then
               echo "! dex file detected,processing"
               mkdir -p $workfile/product/app/$f/oat/arm64
               oat_3=$workfile/product/app/$f/oat/arm64
               dex2oat --dex-file=$workfile/product/app/$f/$f.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_3/$f.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- Process $f success"
               let success_count=success_count+1
            else
               echo "! dex file not detected,skip"
               rm -rf $workfile/product/app/$f
               let failed_count=failed_count+1
               echo "$f ：Process failed,dex file not detected" >>$workfile/log/MIUI_odex_$now_time.log
            fi
         else
            echo "! Faild to unzip $a,apk file does not exist"
            rm -rf $workfile/product/app/$f
            echo "$f ：Process failed,apk file not detected" >>$workfile/log/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
      # /system/product/priv-app
      system_product_priv_app=$(ls -l $workfile/product/priv-app | awk '/^d/ {print $NF}')
      for g in $system_product_priv_app; do
         cd $workfile/product/priv-app/$g
         rm -rf $(find . ! -name '*.apk')
         # unzip
         unzip -q -o *.apk "classes.dex"
         # Are APK decompressed successfully
         if [ $? = 0 ]; then
            echo "- Unzip $g successfully,processing"
            # Judge whether it exists classes.dex
            if [ -f "classes.dex" ]; then
               echo "! dex file detected,processing"
               mkdir -p $workfile/product/priv-app/$g/oat/arm64
               oat_4=$workfile/product/priv-app/$g/oat/arm64
               dex2oat --dex-file=$workfile/product/priv-app/$g/$g.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_4/$g.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- Process $g success"
               let success_count=success_count+1
            else
               echo "! dex file not detected,skip"
               rm -rf $workfile/product/priv-app/$g
               let failed_count=failed_count+1
               echo "$g ：Process failed,dex file not detected" >>$workfile/log/MIUI_odex_$now_time.log
            fi
         else
            echo "! Faild to unzip $g,apk file does not exist"
            rm -rf $workfile/product/priv-app/$g
            echo "$g ：Process failed,apk file not detected" >>$workfile/log/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
   fi
   if [ $is_system_ext == 0 ]; then
      # system/system_ext/app
      system_system_ext_app=$(ls -l $workfile/system_ext/app | awk '/^d/ {print $NF}')
      for h in $system_system_ext_app; do
         cd $workfile/system_ext/app/$h
         rm -rf $(find . ! -name '*.apk')
         # unzip
         unzip -q -o *.apk "classes.dex"
         # Are APK decompressed successfully
         if [ $? = 0 ]; then
            echo "- Unzip $h successfully,processing"
            # Judge whether it exists classes.dex
            if [ -f "classes.dex" ]; then
               echo "! dex file detected,processing"
               mkdir -p $workfile/system_ext/app/$h/oat/arm64
               oat_5=$workfile/system_ext/app/$h/oat/arm64
               dex2oat --dex-file=$workfile/system_ext/app/$h/$h.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_5/$h.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- Process $h successfully"
               let success_count=success_count+1
            else
               echo "! dex file not detected,skip"
               rm -rf $workfile/system_ext/app/$f
               let failed_count=failed_count+1
               echo "$h ：Process failed,dex file not detected" >>$workfile/log/MIUI_odex_$now_time.log
            fi
         else
            echo "! Unzip $h,apk file does not exist"
            rm -rf $workfile/system_ext/app/$f
            echo "$h ：Process failed,apk file not detected" >>$workfile/log/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
      # /system/system_ext/priv-app
      system_system_ext_priv_app=$(ls -l $workfile/system_ext/priv-app | awk '/^d/ {print $NF}')
      for i in $system_system_ext_priv_app; do
         cd $workfile/system_ext/priv-app/$i
         rm -rf $(find . ! -name '*.apk')
         # Unzip 
         unzip -q -o *.apk "classes.dex"
         # Are APK decompressed successfully
         if [ $? = 0 ]; then
            echo "- Unzip $i successfully,processing"
            # Judge whether it exists classes.dex
            if [ -f "classes.dex" ]; then
               echo "! dex file detected,processing"
               mkdir -p $workfile/system_ext/priv-app/$i/oat/arm64
               oat_6=$workfile/system_ext/priv-app/$i/oat/arm64
               dex2oat --dex-file=$workfile/system_ext/priv-app/$i/$i.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_6/$i.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- Process $i successfully"
               let success_count=success_count+1
            else
               echo "! dex file not detected,skip"
               rm -rf $workfile/system_ext/priv-app/$g
               let failed_count=failed_count+1
               echo "$i ：Process failed,dex file not detected" >>$workfile/log/MIUI_odex_$now_time.log
            fi
         else
            echo "! Unzip $i,apk file does not exist"
            rm -rf $workfile/system_ext/priv-app/$g
            echo "$g ：Process failed,apk file not detected" >>$workfile/log/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
   fi
   if [ $is_vendor_app == 0 ]; then
      # system/vendor/app
      system_vendor_app=$(ls -l $workfile/vendor/app | awk '/^d/ {print $NF}')
      for j in $system_system_ext_app; do
         cd $workfile/vendor/app/$j
         rm -rf $(find . ! -name '*.apk')
         # Unzip 
         unzip -q -o *.apk "classes.dex"
         # Are APK decompressed successfully
         if [ $? = 0 ]; then
            echo "- Unzip $j successfully,processing"
            # Judge whether it exists classes.dex
            if [ -f "classes.dex" ]; then
               echo "! dex file detected,processing"
               mkdir -p $workfile/vendor/app/$j/oat/arm64
               oat_7=$workfile/vendor/app/$j/oat/arm64
               dex2oat --dex-file=$workfile/vendor/app/$j/$j.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat_7/$j.odex
               rm -rf $(find . -maxdepth 1 ! -name 'oat')
               echo "- Process$j successfully"
               let success_count=success_count+1
            else
               echo "! dex file not detected,skip"
               rm -rf $workfile/vendor/app/$f
               let failed_count=failed_count+1
               echo "$j ：Process failed,dex file not detected" >>$workfile/log/MIUI_odex_$now_time.log
            fi
         else
            echo "! Unzip $j,apk file does not exist"
            rm -rf $workfile/vendor/app/$f
            echo "$j ：Process failed,apk file not detected" >>$workfile/log/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
   fi
   # process done
   echo "- Total $success_count times success,$failed_count times failed,please check the directory if you need"
   if [ $odex_module == true ]; then
      # making magisk modules
      echo "- Making Magisk module,please wait...."
      mkdir -p /data/adb/modules/miuiodex/system
      touch /data/adb/modules/miuiodex/module.prop
      echo "id=miuiodex" >>/data/adb/modules/miuiodex/module.prop
      echo "name=MIUI ODEX" >>/data/adb/modules/miuiodex/module.prop
      echo "version=$nowversion" >>/data/adb/modules/miuiodex/module.prop
      echo "versionCode=1" >>/data/adb/modules/miuiodex/module.prop
      echo "author=柚稚的孩纸&雄式老方" >>/data/adb/modules/miuiodex/module.prop
      echo "minMagisk=23000" >>/data/adb/modules/miuiodex/module.prop
      ver="$(grep -n "ro.miui.ui.version.name" /system/build.prop | cut -dV -f2)"
      modelversion="$(grep -n "ro.system.build.version.incremental" /system/build.prop | cut -d= -f2)"
      time=$(date "+%Y.%m.%d %H:%M:%S")
      echo -n "description=Process system apps，MIUI$ver $modelversion，Compile time:$time" >>/data/adb/modules/miuiodex/module.prop
      # 移动相关文件
      mv $workfile/* /data/adb/modules/miuiodex/system
      if [ $? = 0 ]; then
         echo "- Module creation is complete, please restart to take effect"
      else
         echo "! Failed to make Magisk module"
      fi
   else
      echo "- The compile ODEX option is not selected, the module will not be generated"
   fi
fi
if [ $choose_odex == 3 ]; then
   echo "- Skip odex process"
   mkdir -p $workfile/packagelist
   touch $workfile/packagelist/packagelist.log
   echo "$(pm list packages -3)" >$workfile/packagelist/packagelist.log
   if [ $choose_dex2oat == 1 ]; then
      # user apps
      apptotalnumber="$(grep -o "package:" $workfile/packagelist/packagelist.log | wc -l)"
      appnumber=0
      echo "Optimizing user apps in speed mode"
      for item in $(pm list packages -3); do
         app=${item:8}
         echo "Optimizing -> $app"
         cmd package compile -m speed $app
         echo "Optimization completed"
         let appnumber=appnumber+1
         percentage=$((appnumber * 100 / apptotalnumber))
         echo "Completed $percentage%   $appnumber / $apptotalnumber"
      done
   else
      if [ $choose_dex2oat == 2 ]; then
         # user apps 
         apptotalnumber="$(grep -o "package:" $workfile/packagelist/packagelist.log | wc -l)"
         appnumber=0
         echo "Optimizing user apps in everything mode"
         for item in $(pm list packages -3); do
            app=${item:8}
            echo "Optimizing -> $app"
            cmd package compile -m everything $app
            echo "Optimization completed"
            let appnumber=appnumber+1
            percentage=$((appnumber * 100 / apptotalnumber))
            echo "Completed $percentage%   $appnumber / $apptotalnumber"
         done
      fi
   fi
else
   mkdir -p $workfile/packagelist
   touch $workfile/packagelist/packagelist.log
   echo "$(pm list packages -3)" >$workfile/packagelist/packagelist.log
   if [ $choose_dex2oat == 1 ]; then
      # user apps
      apptotalnumber="$(grep -o "package:" $workfile/packagelist/packagelist.log | wc -l)"
      appnumber=0
      echo "Optimizing user apps in speed mode"
      for item in $(pm list packages -3); do
         app=${item:8}
         echo "Optimizing -> $app"
         cmd package compile -m speed $app
         echo "Optimization completed"
         let appnumber=appnumber+1
         percentage=$((appnumber * 100 / apptotalnumber))
         echo "Completed $percentage%   $appnumber / $apptotalnumber"
      done
   else
      if [ $choose_dex2oat == 2 ]; then
         # user apps
         apptotalnumber="$(grep -o "package:" $workfile/packagelist/packagelist.log | wc -l)"
         appnumber=0
         echo "Optimizing user apps in everything mode"
         for item in $(pm list packages -3); do
            app=${item:8}
            echo "Optimizing -> $app"
            cmd package compile -m everything $app
            echo "Optimization completed"
            let appnumber=appnumber+1
            percentage=$((appnumber * 100 / apptotalnumber))
            echo "Completed $percentage%   $appnumber / $apptotalnumber"
         done
      fi
   fi
fi
# remove unecessary
rm -rf $workfile
echo "- Done！"
