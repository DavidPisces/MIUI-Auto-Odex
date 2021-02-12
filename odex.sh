#!/bin/bash
# MIUI ODEX项目贡献者：柚稚的孩纸(zjw2017) 雄氏老方(DavidPisces)
nowversion=5.1
workfile=/storage/emulated/0/MIUI_odex
success_count=0
failed_count=0
now_time=$(date '+%Y%m%d_%H:%M:%S')
echo "- 正在准备环境"
# rm
rm -rf $workfile
# mkdir
echo "- 正在创建目录"
mkdir -p /storage/emulated/0/MIUI_odex/log
mkdir -p /storage/emulated/0/MIUI_odex/app
mkdir -p /storage/emulated/0/MIUI_odex/priv-app
mkdir -p /storage/emulated/0/MIUI_odex/framework
if [ -d "/system/product/app" ];then
   mkdir -p /storage/emulated/0/MIUI_odex/product/app
fi
if [ -d "/system/product/priv-app" ];then
   mkdir -p /storage/emulated/0/MIUI_odex/product/priv-app
   is_product=0
else
   is_product=1
fi
# log
touch $workfile/log/MIUI_odex_$now_time.log

# clear screen
clear

# choose odex mod
echo "*************************************************"
echo " "
echo " "
echo "                   MIUI ODEX"
echo "                      $nowversion"
echo " "
echo "*************************************************"
echo -e "\n- 您希望以什么模式编译Odex\n"
echo "[1] Simple (耗时较少,占用空间少，仅编译重要应用)"
echo "[2] Complete (耗时较长，占用空间大，完整编译)"
echo "[3] Skip ODEX 不进行ODEX编译"
echo "[4] Update From Github 从Github更新脚本"
echo "[5] Update From Gitee 从Gitee更新(国内源)"
echo "[6] Quit 退出"
echo -e "\n请输入选项"
read choose_odex
clear

# Update Mode 1
if [ $choose_odex == 4 ] ; then
# Github Raw
  echo "- 正在查询Github最新版本，请坐和放宽"
  curl -s -o version https://raw.githubusercontent.com/DavidPisces/MIUI-Auto-Odex/master/version
  latestversion=$(cat version)
  latestshname="odex.sh"
  lastname="odex$(cat version).sh"
  latesturl="https://raw.githubusercontent.com/DavidPisces/MIUI-Auto-Odex/master/odex.sh"
  clear
  is_update=$(echo "$latestversion > $nowversion" | bc)
  if [ $is_update != 0 ] ; then
      echo "! 发现新版本$latestversion，是否更新"
	  echo "  [y] 更新"
	  echo "  [n] 取消"
	  read choose_update
	  clear
	  if [ $choose_update == "y" ] ;then
	     echo "- 正在下载更新，请坐和放宽"
	     curl -s -o odex$latestversion.sh $latesturl
		 clear
         if [ $? -eq 0 ]; then
            echo "- 新版本已下载完毕，请退出重新运行odex.sh"
            rm -rf version
	        mv "odex$latestversion.sh" "$latestshname"
            exit
		 else
		    echo "! 下载失败"
         fi
	  else
	     echo "# 已取消"
		 rm -rf version
		 exit
	  fi
   else
      echo "- 未发现新版本"
	  echo "  当前版本：$nowversion"
	  echo "  Github版本：$latestversion"
	  echo "  是否重新下载？"
	  echo "[y] 下载"
	  echo "[n] 取消"
	  read choose_update
	  clear
	  if [ $choose_update == "y" ] ;then
	     echo "- 正在下载更新，请坐和放宽"
	     curl -s -o odex$latestversion.sh $latesturl
		 clear
         if [ $? -eq 0 ]; then
            echo "- 下载完毕，请退出重新运行odex.sh"
            rm -rf version
	        mv "odex$latestversion.sh" "$latestshname"
            exit
		 else
		    echo "! 下载失败"
         fi
	  else
		 echo "# 已取消"
		 rm -rf version
		 exit
	  fi	
	  
	  rm -rf version
	  exit
   fi
fi

# Update Mode 2
if [ $choose_odex == 5 ] ; then
# Gitee Raw
  echo "- 正在查询Gitee最新版本，请坐和放宽"
  curl -s -o version https://gitee.com/David-GithubClone/MIUI-Auto-Odex/raw/master/version
  latestversion=$(cat version)
  latestshname="odex.sh"
  lastname="odex$(cat version).sh"
  latesturl="https://gitee.com/David-GithubClone/MIUI-Auto-Odex/raw/master/odex.sh"
  clear
  is_update=$(echo "$latestversion > $nowversion" | bc)
  if [ $is_update != 0 ] ; then
      echo "! 发现新版本$latestversion，是否更新"
	  echo "  [y] 更新"
	  echo "  [n] 取消"
	  read choose_update
	  clear
	  if [ $choose_update == "y" ] ;then
	     echo "- 正在下载更新，请坐和放宽"
	     curl -s -o odex$latestversion.sh $latesturl
		 clear
         if [ $? -eq 0 ]; then
            echo "- 新版本已下载完毕，请退出重新运行odex.sh"
            rm -rf version
	        mv "odex$latestversion.sh" "$latestshname"
            exit
		 else
		    echo "! 下载失败"
         fi
	  else
	     echo "# 已取消"
		 rm -rf version
		 exit
	  fi
   else
      echo "- 未发现新版本"
	  echo "  当前版本：$nowversion"
	  echo "  Gitee版本：$latestversion"
	  echo "  是否下载？"
	  echo "[y] 下载"
	  echo "[n] 取消"
	  read choose_update
	  clear
	  if [ $choose_update == "y" ] ;then
	     echo "- 正在下载更新，请坐和放宽"
	     curl -s -o odex$latestversion.sh $latesturl
		 clear
         if [ $? -eq 0 ]; then
            echo "- 下载完毕，请退出重新运行odex.sh"
            rm -rf version
	        mv "odex$latestversion.sh" "$latestshname"
            exit
		 else
		    echo "! 下载失败"
         fi
	  else
		 echo "# 已取消"
		 rm -rf version
		 exit
	  fi	
	  
	  rm -rf version
	  exit
   fi
fi

if [ $choose_odex == 6 ] ; then
   echo "- 已退出"
   exit
else
   # choose dex2oat mod
   echo "*************************************************"
   echo " "
   echo " "
   echo "                   MIUI ODEX"
   echo "                     $nowversion"
   echo " "
   echo "*************************************************"
   echo -e "\n- 您希望以什么模式进行Dex2oat\n"
   echo "[1] Speed (快速编译,耗时较短)"
   echo "[2] Everything (完整编译,耗时较长)"
   echo "[3] 不进行Dex2oat编译"
   echo -e "\n请输入选项"
   read choose_dex2oat
fi

clear

if [ $choose_odex == 3 ] ; then
	echo "- 跳过odex编译，不会生成模块"
	odex_module=false
else
    rm -rf /data/adb/modules/miuiodex
    if [ $choose_odex == 1 ] ; then
        echo "- 正在以Simple(简单)模式编译"
        cp -r /system/app/miui $workfile/app
        cp -r /system/app/miuisystem $workfile/app
        cp -r /system/app/XiaomiServiceFramework $workfile/app
        cp -r /system/priv-app/MiuiCamera $workfile/priv-app
        cp -r /system/priv-app/MiuiGallery $workfile/priv-app
        cp -r /system/priv-app/MiuiHome $workfile/priv-app
        cp -r /system/priv-app/MiuiSystemUI $workfile/priv-app
        cp -r /system/priv-app/SecurityCenter $workfile/priv-app
        cp -r /system/product/priv-app/Settings $workfile/product/priv-app
		cp -r /system/framework/*.jar $workfile/framework	
        echo "- 文件复制完成，开始执行"
	    odex_module=true
     else
        if [ $choose_odex == 2 ] ;then
          echo "- 正在以Complete(完整)模式编译"
          # copy files to path
          cp -r /system/app/* $workfile/app
          cp -r /system/priv-app/* $workfile/priv-app
          cp -r /system/product/app/* $workfile/product/app
          cp -r /system/product/priv-app/* $workfile/product/priv-app
		  cp -r /system/framework/*.jar $workfile/framework
          echo "- 文件复制完成，开始执行"
	      odex_module=true
		fi
     fi
  fi


# system/framework
jar=$(ls -l $workfile/framework | awk 'NR>1 {print $NF}')
for j in $jar
do
mkdir -p $workfile/framework/oat/arm
mkdir -p $workfile/framework/oat/arm64
oat32=$workfile/framework/oat/arm
oat64=$workfile/framework/oat/arm64
jarhead=$(basename $j .jar)
echo "- 正在处理$jarhead.jar"
dex2oat --dex-file=$workfile/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64/$jarhead.odex
dex2oat --dex-file=$workfile/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32/$jarhead.odex
rm -rf $workfile/framework/$jarhead.jar
echo "- 处理$jarhead.jar完成"
done
# system/app
dirapp=$(ls -l $workfile/app | awk '/^d/ {print $NF}')
for i in $dirapp
do
   cd $workfile/app/$i
# unzip
   unzip -q -o *.apk "classes.dex"
# whether unzip apk success
if [ $? = 0 ] ; then
   echo "- 解包$i成功，开始处理"
# 判断是否存在classes.dex
   if [ -f "classes.dex" ] ; then
      echo "! 已检测到dex文件，开始编译"
	  mkdir -p $workfile/app/$i/oat/arm64
      oat=$workfile/app/$i/oat/arm64
	  dex2oat --dex-file=$workfile/app/$i/$i.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat/$i.odex
      ls $workfile/app/$i/ | grep -v oat | xargs rm
	  echo "- 已完成对$i的odex分离处理"
	  let success_count=success_count+1
   else
      echo "! 未检测到dex文件，跳过编译"
	  rm -rf $workfile/app/$i
	  let failed_count=failed_count+1
	  echo "$i ：编译失败，没有dex文件" >> $workfile/log/MIUI_odex_$now_time.log
   fi
else
   echo "! 解压$i失败，没有apk文件"
   rm -rf $workfile/app/$i
   echo "$i ：编译失败，没有apk文件" >> $workfile/log/MIUI_odex_$now_time.log
   let failed_count=failed_count+1
fi
done

# system/priv-app
dirpriv=$(ls -l $workfile/priv-app | awk '/^d/ {print $NF}')
for p in $dirpriv
do
   cd $workfile/priv-app/$p
# unzip
   unzip -q -o *.apk "classes.dex"
# whether unzip apk success
if [ $? = 0 ] ; then
   echo "- 解包$p成功，开始处理"
# 判断是否存在classes.dex
   if [ -f "classes.dex" ] ; then
      echo "! 已检测到dex文件，开始编译"
	  mkdir -p $workfile/priv-app/$p/oat/arm64
      oat=$workfile/priv-app/$p/oat/arm64
	  dex2oat --dex-file=$workfile/priv-app/$p/$p.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat/$p.odex
      ls $workfile/app/$p | grep -v oat | xargs rm
	  echo "- 已完成对$p的odex分离处理"
	  let success_count=success_count+1
   else
      echo "! 未检测到dex文件，跳过编译"
	  rm -rf $workfile/priv-app/$p
	  let failed_count=failed_count+1
	  echo "$p ：编译失败，没有dex文件" >> $workfile/log/MIUI_odex_$now_time.log
   fi
else
   echo "! 解压$p失败，没有apk文件"
   rm -rf $workfile/priv-app/$p
   echo "$p ：编译失败，没有apk文件" >> $workfile/log/MIUI_odex_$now_time.log
   let failed_count=failed_count+1
fi
done

# system/product/app
productapp=$(ls -l $workfile/product/app | awk '/^d/ {print $NF}')
for a in $productapp
do
   cd $workfile/product/app/$a
# unzip
   unzip -q -o *.apk "classes.dex"
# whether unzip apk success
if [ $? = 0 ] ; then
   echo "- 解包$a成功，开始处理"
# 判断是否存在classes.dex
   if [ -f "classes.dex" ] ; then
      echo "! 已检测到dex文件，开始编译"
	  mkdir -p $workfile/product/app/$a/oat/arm64
      oat=$workfile/product/app/$a/oat/arm64
	  dex2oat --dex-file=$workfile/product/app/$a/$a.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat/$a.odex
	  ls $workfile/app/$a | grep -v oat | xargs rm
	  echo "- 已完成对$a的odex分离处理"
	  let success_count=success_count+1
   else
      echo "! 未检测到dex文件，跳过编译"
	  rm -rf $workfile/product/app/$a
	  let failed_count=failed_count+1
	  echo "$a ：编译失败，没有dex文件" >> $workfile/log/MIUI_odex_$now_time.log
   fi
else
   echo "! 解压$a失败，没有apk文件"
   rm -rf $workfile/product/app/$a
   echo "$a ：编译失败，没有apk文件" >> $workfile/log/MIUI_odex_$now_time.log
   let failed_count=failed_count+1
fi
done

# system/product/priv-app
productprivapp=$(ls -l $workfile/product/priv-app | awk '/^d/ {print $NF}')
for b in $productprivapp
do
   cd $workfile/product/priv-app/$b
# unzip
   unzip -q -o *.apk "classes.dex"
# whether unzip apk success
if [ $? = 0 ] ; then
   echo "- 解包$b成功，开始处理"
# 判断是否存在classes.dex
   if [ -f "classes.dex" ] ; then
      echo "! 已检测到dex文件，开始编译"
	  mkdir -p $workfile/product/priv-app/$b/oat/arm64
      oat=$workfile/product/priv-app/$b/oat/arm64
	  dex2oat --dex-file=$workfile/product/priv-app/$b/$b.apk --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat/$b.odex
	  ls $workfile/app/$b | grep -v oat | xargs rm
	  echo "- 已完成对$b的odex分离处理"
	  let success_count=success_count+1
   else
      echo "! 未检测到dex文件，跳过编译"
	  rm -rf $workfile/product/priv-app/$b
	  let failed_count=failed_count+1
	  echo "$b ：编译失败，没有dex文件" >> $workfile/log/MIUI_odex_$now_time.log
   fi
else
   echo "! 解压$b失败，没有apk文件"
   rm -rf $workfile/product/priv-app/$b
   echo "$b ：编译失败，没有apk文件" >> $workfile/log/MIUI_odex_$now_time.log
   let failed_count=failed_count+1
fi
done
# end
echo "- 共$success_count次成功，$failed_count次失败，请检查对应目录"
echo "# 正在查找未删除的apk dex lib"
trash_apk=$(find $workfile -name "*.apk")
trash_dex=$(find $workfile -name "*.dex")
trash_lib=$(find $workfile -name "*lib")
rm -rf $trash_apk
rm -rf $trash_dex
rm -rf $trash_lib
echo "- 清除完成"
if [ $odex_module == true ] ; then
   # 生成模块
   echo "- 正在制作模块，请坐和放宽"
   mkdir -p /data/adb/modules/miuiodex/system
   touch /data/adb/modules/miuiodex/module.prop
   echo "id=miuiodex" >> /data/adb/modules/miuiodex/module.prop
   echo "name=MIUI ODEX" >> /data/adb/modules/miuiodex/module.prop
   echo "version=$nowversion" >> /data/adb/modules/miuiodex/module.prop
   echo "versionCode=1" >> /data/adb/modules/miuiodex/module.prop
   echo "author=柚稚的孩纸&雄式老方" >> /data/adb/modules/miuiodex/module.prop
   echo "minMagisk=19000" >> /data/adb/modules/miuiodex/module.prop
   model="`grep -n "ro.product.system.model" /system/build.prop | cut -d= -f2`"
   ver="`grep -n "ro.miui.ui.version.name" /system/build.prop | cut -dV -f2`"
   modelversion="`grep -n "ro.system.build.version.incremental" /system/build.prop | cut -d= -f2`"
   time=$(date "+%Y年%m月%d日 %H:%M:%S")
   echo -n "description=分离系统软件ODEX，MIUI$ver $modelversion，编译时间$time [Build with $model]" >> /data/adb/modules/miuiodex/module.prop
   mv $workfile/* /data/adb/modules/miuiodex/system
   if [ $? = 0 ] ; then
      mv /data/adb/modules/miuiodex/system/log $workfile
      rm -rf /data/adb/modules/miuiodex/system/packagelist
      echo "- 模块制作完成，请重启生效"
   else
      echo "! 模块制作失败"
   fi
else
  echo "- 未选择编译odex选项，不会生成模块"
fi

if [ $choose_odex == 3 ] ;then 
   echo "- 不进行ODEX编译"
   mkdir -p $workfile/packagelist
   touch $workfile/packagelist/packagelist.log
   echo "`pm list packages -3`" > $workfile/packagelist/packagelist.log
   if [ $choose_dex2oat == 3 ] ; then
      echo "不进行Dex2oat"
	  exit
   fi
   if [ $choose_dex2oat == 1 ] ; then
      # 用户应用
       apptotalnumber="`grep -o "package:" $workfile/packagelist/packagelist.log | wc -l`"
       appnumber=0
       echo "正在以Speed模式优化用户软件"
       for item in `pm list packages -3`
       do
           app=${item:8}
		   echo "正在优化 -> $app"
           cmd package compile -m speed $app
           echo "应用优化完成"
           let appnumber=appnumber+1
           percentage=$((appnumber*100/apptotalnumber))
           echo "已完成 $percentage%   $appnumber / $apptotalnumber"
       done
   else
       if [ $choose_dex2oat == 2 ] ;then
          # 用户应用
          apptotalnumber="`grep -o "package:" $workfile/packagelist/packagelist.log | wc -l`"
          appnumber=0
          echo "正在以Everything模式优化用户软件"
          for item in `pm list packages -3`
          do
              app=${item:8}
		      echo "正在优化 -> $app"
              cmd package compile -m everything $app
              echo "应用优化完成"
              let appnumber=appnumber+1
              percentage=$((appnumber*100/apptotalnumber))
              echo "已完成 $percentage%   $appnumber / $apptotalnumber"
          done
	   fi
	fi
else
   mkdir -p $workfile/packagelist
   touch $workfile/packagelist/packagelist.log
   echo "`pm list packages -3`" > $workfile/packagelist/packagelist.log
   if [ $choose_dex2oat == 3 ] ; then
      echo "- 不进行Dex2oat"
      exit
   fi
   if [ $choose_dex2oat == 1 ] ; then
      # 用户应用
       apptotalnumber="`grep -o "package:" $workfile/packagelist/packagelist.log | wc -l`"
       appnumber=0
       echo "正在以Speed模式优化用户软件"
       for item in `pm list packages -3`
       do
           app=${item:8}
		   echo "正在优化 -> $app"
           cmd package compile -m speed $app
           echo "应用优化完成"
           let appnumber=appnumber+1
           percentage=$((appnumber*100/apptotalnumber))
           echo "已完成 $percentage%   $appnumber / $apptotalnumber"
       done
   else
       if [ $choose_dex2oat == 2 ] ;then
          # 用户应用
          apptotalnumber="`grep -o "package:" $workfile/packagelist/packagelist.log | wc -l`"
          appnumber=0
          echo "正在以Everything模式优化用户软件"
          for item in `pm list packages -3`
          do
              app=${item:8}
		      echo "正在优化 -> $app"
              cmd package compile -m everything $app
              echo "应用优化完成"
              let appnumber=appnumber+1
              percentage=$((appnumber*100/apptotalnumber))
              echo "已完成 $percentage%   $appnumber / $apptotalnumber"
          done
	   fi
	fi
fi
echo "- 完成！"
