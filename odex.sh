#!/bin/bash
# MIUI ODEX项目贡献者：柚稚的孩纸(zjw2017) 雄氏老方(DavidPisces)
nowversion=6.3
workfile=/storage/emulated/0/MIUI_odex/system
success_count=0
failed_count=0
now_time=$(date '+%Y%m%d_%H:%M:%S')
echo "- 正在准备环境"
# rm
rm -rf $workfile
# 创建目录
echo "- 正在创建目录"
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
# 获取系统SDK
SDK=$(getprop ro.system.build.version.sdk)
# 获取MIUI版本号
MIUI_version=$(getprop ro.miui.ui.version.name)
# 输出日志文件
touch /storage/emulated/0/MIUI_odex/log/MIUI_odex_$now_time.log
# 清理屏幕
clear
update_online() {
   echo "*************************************************"
   echo " "
   echo " "
   echo "                   MIUI ODEX"
   echo "                     $nowversion"
   echo " "
   echo " "
   echo "*************************************************"
   echo -e "\n- 请确认更新的方式\n"
   echo "[1] Update From Github 从Github更新脚本"
   echo "[2] Update From Gitee 从Gitee更新(国内源)"
   echo -e "\n请输入选项"
   read update_mode
   # Update Mode 1
   if [ $update_mode == 1 ]; then
      clear
      # Github Raw
      echo "- 正在查询Github最新版本，请坐和放宽"
      curl -s -O https://raw.githubusercontent.com/DavidPisces/MIUI-Auto-Odex/master/version.prop
      source version.prop
      latestshname="odex.sh"
      lastname="odex$version.sh"
      latesturl="https://raw.githubusercontent.com/DavidPisces/MIUI-Auto-Odex/master/odex.sh"
      clear
      if [ $version != $nowversion ]; then
         echo "! 发现新版本$version，是否更新"
         echo "  版本描述如下："
         echo -e "  $description"
         echo "  [y] 更新"
         echo "  [n] 取消"
         read choose_update
         clear
         if [ $choose_update == "y" ]; then
            echo "- 正在下载更新，请坐和放宽"
            curl -s -o odex$version.sh $latesturl
            clear
            if [ $? -eq 0 ]; then
               echo "- 新版本已下载完毕，请退出重新运行odex.sh"
               rm -rf version.prop
               mv "odex$version.sh" "$latestshname"
               exit
            else
               echo "! 下载失败"
            fi
         else
            echo "# 已取消"
            rm -rf version.prop
            exit
         fi
      else
         echo "- 未发现新版本"
         echo "  当前版本：$nowversion"
         echo -e "  Github版本：$version\n"
         echo "- 版本描述如下："
         echo -e "  $description\n"
         echo "- 是否重新下载？"
         echo "[y] 下载"
         echo "[n] 取消"
         read choose_update
         clear
         if [ $choose_update == "y" ]; then
            echo "- 正在下载更新，请坐和放宽"
            curl -s -o odex$version.sh $latesturl
            clear
            if [ $? -eq 0 ]; then
               echo "- 下载完毕，请退出重新运行odex.sh"
               rm -rf version.prop
               mv "odex$version.sh" "$latestshname"
               exit
            else
               echo "! 下载失败"
            fi
         else
            echo "# 已取消"
            rm -rf version.prop
            exit
         fi

         rm -rf version.prop
         exit
      fi
   fi

   # Update Mode 2
   if [ $update_mode == 2 ]; then
      clear
      # Gitee Raw
      echo "- 正在查询Gitee最新版本，请坐和放宽"
      curl -s -O https://gitee.com/David-GithubClone/MIUI-Auto-Odex/raw/master/version.prop
      source version.prop
      latestshname="odex.sh"
      lastname="odex$version.sh"
      latesturl="https://gitee.com/David-GithubClone/MIUI-Auto-Odex/raw/master/odex.sh"
      clear
      if [ $version != $nowversion ]; then
         echo "! 发现新版本$version，是否更新"
         echo "  版本描述如下："
         echo -e "  $description"
         echo "  [y] 更新"
         echo "  [n] 取消"
         read choose_update
         clear
         if [ $choose_update == "y" ]; then
            echo "- 正在下载更新，请坐和放宽"
            curl -s -o odex$version.sh $latesturl
            clear
            if [ $? -eq 0 ]; then
               echo "- 新版本已下载完毕，请退出重新运行odex.sh"
               rm -rf version.prop
               mv "odex$version.sh" "$latestshname"
               exit
            else
               echo "! 下载失败"
            fi
         else
            echo "# 已取消"
            rm -rf version.prop
            exit
         fi
      else
         echo "- 未发现新版本"
         echo "  当前版本：$nowversion"
         echo -e "  Gitee版本：$version\n"
         echo "- 版本描述如下："
         echo -e "  $description\n"
         echo "- 是否重新下载？"
         echo "[y] 下载"
         echo "[n] 取消"
         read choose_update
         clear
         if [ $choose_update == "y" ]; then
            echo "- 正在下载更新，请坐和放宽"
            curl -s -o odex$version.sh $latesturl
            clear
            if [ $? -eq 0 ]; then
               echo "- 下载完毕，请退出重新运行odex.sh"
               rm -rf version.prop
               mv "odex$version.sh" "$latestshname"
               exit
            else
               echo "! 下载失败"
            fi
         else
            echo "# 已取消"
            rm -rf version.prop
            exit
         fi
         rm -rf version.prop
         exit
      fi
   fi
}

# 核心部分
echo "*************************************************"
echo " "
echo " "
echo "                   MIUI ODEX"
echo "                     $nowversion"
echo " "
echo " "
echo "*************************************************"
echo -e "\n- 请输入选项\n"
echo "[1] Simple (耗时较少,占用空间少，仅编译重要应用)"
echo "[2] Complete (耗时较长，占用空间大，完整编译)"
echo "[3] Skip ODEX 不进行ODEX编译"
echo "[4] Update 更新"
echo "[5] Exit 退出"
echo -e "\n请输入选项"
read choose_odex
clear
if [ $choose_odex == 4 ]; then
   update_online
fi

if [ $choose_odex == 5 ]; then
   echo "- 已退出"
   exit
fi

if [ $choose_odex == 3 ]; then
   echo "- 跳过odex编译，不会生成模块"
   odex_module=false
   # 选择Dex2oat方式
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
   echo -e "\n请输入选项"
   read choose_dex2oat
else
   # 删除上一次编译结果
   rm -rf /data/adb/modules/miuiodex
   # 选择Dex2oat方式
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
      echo "- 文件复制完成，开始执行"
      odex_module=true
   else
      if [ $choose_odex == 2 ]; then
         echo "- 正在以Complete(完整)模式编译"
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
         echo "- 文件复制完成，开始执行"
         odex_module=true
      fi
   fi
fi
# 清理屏幕
clear
if [ $choose_odex != 3 ]; then
   echo "- 开始处理framework"
   # /system/framework
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
         echo "- 开始处理$b"
         dex2oat --dex-file=$workfile/product/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64_2/$jarhead.odex
         dex2oat --dex-file=$workfile/product/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32_2/$jarhead.odex
         rm -rf $workfile/product/framework/$jarhead.jar
         echo "- 已完成对$b的处理"
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
         echo "- 开始处理$c"
         dex2oat --dex-file=$workfile/system_ext/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm64 --oat-file=$oat64_3/$jarhead.odex
         dex2oat --dex-file=$workfile/system_ext/framework/$jarhead.jar --compiler-filter=everything --instruction-set=arm --oat-file=$oat32_3/$jarhead.odex
         rm -rf $workfile/system_ext/framework/$jarhead.jar
         echo "- 已完成对$c的处理"
      done
   fi
   echo "- 已完成对framework的处理"
   # system/app
   system_app=$(ls -l $workfile/app | awk '/^d/ {print $NF}')
   for d in $system_app; do
      cd $workfile/app/$d
      rm -rf $(find . ! -name '*.apk')
      # 解压
      unzip -q -o *.apk "classes.dex"
      # 解压apk是否成功
      if [ $? = 0 ]; then
         echo "- 解包$d成功，开始处理"
         # 判断是否存在classes.dex
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
            echo "$d ：编译失败，没有dex文件" >>$workfile/log/MIUI_odex_$now_time.log
         fi
      else
         echo "! 解压$d失败，没有apk文件"
         rm -rf $workfile/app/$d
         echo "$d ：编译失败，没有apk文件" >>$workfile/log/MIUI_odex_$now_time.log
         let failed_count=failed_count+1
      fi
   done
   # system/priv-app
   system_priv_app=$(ls -l $workfile/priv-app | awk '/^d/ {print $NF}')
   for e in $system_priv_app; do
      cd $workfile/priv-app/$e
      rm -rf $(find . ! -name '*.apk')
      # 解压
      unzip -q -o *.apk "classes.dex"
      # 解压apk是否成功
      if [ $? = 0 ]; then
         echo "- 解包$e成功，开始处理"
         # 判断是否存在classes.dex
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
            echo "$e ：编译失败，没有dex文件" >>$workfile/log/MIUI_odex_$now_time.log
         fi
      else
         echo "! 解压$e失败，没有apk文件"
         rm -rf $workfile/priv-app/$e
         echo "$e ：编译失败，没有apk文件" >>$workfile/log/MIUI_odex_$now_time.log
         let failed_count=failed_count+1
      fi
   done
   if [ $is_product == 0 ]; then
      # system/product/app
      system_product_app=$(ls -l $workfile/product/app | awk '/^d/ {print $NF}')
      for f in $system_product_app; do
         cd $workfile/product/app/$f
         rm -rf $(find . ! -name '*.apk')
         # 解压
         unzip -q -o *.apk "classes.dex"
         # 解压apk是否成功
         if [ $? = 0 ]; then
            echo "- 解包$f成功，开始处理"
            # 判断是否存在classes.dex
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
               echo "$f ：编译失败，没有dex文件" >>$workfile/log/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$a失败，没有apk文件"
            rm -rf $workfile/product/app/$f
            echo "$f ：编译失败，没有apk文件" >>$workfile/log/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
      # /system/product/priv-app
      system_product_priv_app=$(ls -l $workfile/product/priv-app | awk '/^d/ {print $NF}')
      for g in $system_product_priv_app; do
         cd $workfile/product/priv-app/$g
         rm -rf $(find . ! -name '*.apk')
         # 解压
         unzip -q -o *.apk "classes.dex"
         # 解压apk是否成功
         if [ $? = 0 ]; then
            echo "- 解包$g成功，开始处理"
            # 判断是否存在classes.dex
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
               echo "$g ：编译失败，没有dex文件" >>$workfile/log/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$g失败，没有apk文件"
            rm -rf $workfile/product/priv-app/$g
            echo "$g ：编译失败，没有apk文件" >>$workfile/log/MIUI_odex_$now_time.log
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
         # 解压
         unzip -q -o *.apk "classes.dex"
         # 解压apk是否成功
         if [ $? = 0 ]; then
            echo "- 解包$h成功，开始处理"
            # 判断是否存在classes.dex
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
               rm -rf $workfile/system_ext/app/$f
               let failed_count=failed_count+1
               echo "$h ：编译失败，没有dex文件" >>$workfile/log/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$h失败，没有apk文件"
            rm -rf $workfile/system_ext/app/$f
            echo "$h ：编译失败，没有apk文件" >>$workfile/log/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
      # /system/system_ext/priv-app
      system_system_ext_priv_app=$(ls -l $workfile/system_ext/priv-app | awk '/^d/ {print $NF}')
      for i in $system_system_ext_priv_app; do
         cd $workfile/system_ext/priv-app/$i
         rm -rf $(find . ! -name '*.apk')
         # 解压
         unzip -q -o *.apk "classes.dex"
         # 解压apk是否成功
         if [ $? = 0 ]; then
            echo "- 解包$i成功，开始处理"
            # 判断是否存在classes.dex
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
               rm -rf $workfile/system_ext/priv-app/$g
               let failed_count=failed_count+1
               echo "$i ：编译失败，没有dex文件" >>$workfile/log/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$i失败，没有apk文件"
            rm -rf $workfile/system_ext/priv-app/$g
            echo "$g ：编译失败，没有apk文件" >>$workfile/log/MIUI_odex_$now_time.log
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
         # 解压
         unzip -q -o *.apk "classes.dex"
         # 解压apk是否成功
         if [ $? = 0 ]; then
            echo "- 解包$j成功，开始处理"
            # 判断是否存在classes.dex
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
               rm -rf $workfile/vendor/app/$f
               let failed_count=failed_count+1
               echo "$j ：编译失败，没有dex文件" >>$workfile/log/MIUI_odex_$now_time.log
            fi
         else
            echo "! 解压$j失败，没有apk文件"
            rm -rf $workfile/vendor/app/$f
            echo "$j ：编译失败，没有apk文件" >>$workfile/log/MIUI_odex_$now_time.log
            let failed_count=failed_count+1
         fi
      done
   fi
   # 执行结束
   echo "- 共$success_count次成功，$failed_count次失败，请检查对应目录"
   if [ $odex_module == true ]; then
      # 生成模块
      echo "- 正在制作模块，请坐和放宽"
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
      time=$(date "+%Y年%m月%d日 %H:%M:%S")
      echo -n "description=分离系统软件ODEX，MIUI$ver $modelversion，编译时间$time" >>/data/adb/modules/miuiodex/module.prop
      # 移动相关文件
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
      # 用户应用
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
         # 用户应用
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
      # 用户应用
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
         # 用户应用
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
# 删除残留文件
rm -rf $workfile
echo "- 完成！"
