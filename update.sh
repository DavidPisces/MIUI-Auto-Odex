# 自动更新部分
# choose Update method
echo "*************************************************"
echo " "
echo " "
echo "                   MIUI ODEX"
echo "                     $nowversion"
echo " "
echo " "
echo "*************************************************"
echo -e "\n- 是否检测更新\n"
echo "  [y] 更新"
echo "  [n] 取消"
echo -e "\n请输入选项"
read if_update
if [ $if_update == y ] ; then
   clear
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
   read update_method
   if [ $update_method == 1 ] ; then
      clear
	  # Github Raw
	  echo "- 正在查询Github最新版本，请坐和放宽"
      curl -s -o version_zjw2017 https://raw.githubusercontent.com/zjw2017/odex-For-MIUI-WeeklyReleases/master/version
	  curl -s -o version_DavidPisces https://raw.githubusercontent.com/DavidPisces/MIUI-Auto-Odex/master/version
	  zjw2017_latesturl="https://raw.githubusercontent.com/zjw2017/odex-For-MIUI-WeeklyReleases/master/odex.sh"
	  DavidPisces_latesturl="https://raw.githubusercontent.com/DavidPisces/MIUI-Auto-Odex/master/odex.sh"
	  DavidPisces=$(cat version_DavidPisces)
	  zjw2017=$(cat version_zjw2017)
	  DavidPisces_New=$(echo "$DavidPisces > $zjw2017" | bc) 
	  zjw2017_New=$(echo "$zjw2017 > $DavidPisces" | bc)
	  if [ $zjw2017 == $DavidPisces ] ; then
         echo "- 未发现新版本"
	     echo "  zjw2017当前版本：$zjw2017"
	     echo "  DavidPisces当前版本：$DavidPisces"
	     echo "  是否重新下载？"
	     echo "  [y] 下载"
	     echo "  [n] 取消"
		 echo -e "\n请输入选项"
	     read redownload
	     if [ $redownload == "y" ] ;then
	        clear
			echo "- 正在下载更新，请坐和放宽"
			rm -rf odex.sh
	        curl -s -o odex.sh $zjw2017_latesturl
            if [ $? -eq 0 ]; then
               echo "- 下载完毕，请退出重新运行odex.sh"
               rm -rf version_DavidPisces
			   rm -rf version_zjw2017
               exit
		    else
		       echo "! 下载失败"
			   rm -rf version_DavidPisces
			   rm -rf version_zjw2017
            fi
	     else
		    echo "# 已取消"
		    rm -rf version_DavidPisces
			rm -rf version_zjw2017
		    exit
	     fi	
	  else
	     if [ $DavidPisces_New = 1 ] ; then
            echo "! 发现新版本$DavidPisces，是否更新"
			echo "！作者： 雄氏老方"
	        echo "  [y] 更新"
	        echo "  [n] 取消"
		    echo -e "\n请输入选项"
	        read update_choice
	        if [ $update_choice == "y" ] ;then
	           clear
		       echo "- 正在下载更新，请坐和放宽"
		       rm -rf odex.sh
	           curl -s -o odex.sh $DavidPisces_latesturl
               if [ $? -eq 0 ]; then
                  echo "- 新版本已下载完毕，请退出重新运行odex.sh"
                  rm -rf version_DavidPisces
			      rm -rf version_zjw2017
                  exit
		       else
		          echo "! 下载失败"
			      rm -rf version_DavidPisces
			      rm -rf version_zjw2017
               fi
	        else
	           echo "已取消"
		       rm -rf version_DavidPisces
			   rm -rf version_zjw2017
		       exit
	        fi
         else
		    if [ $zjw2017_New = 1 ] ; then
               echo "! 发现新版本$zjw2017，是否更新"
			   echo "！作者： 柚稚的孩纸"
	           echo "  [y] 更新"
	           echo "  [n] 取消"
		       echo -e "\n请输入选项"
	           read update_choice
	           if [ $update_choice == "y" ] ;then
	              clear
		          echo "- 正在下载更新，请坐和放宽"
		          rm -rf odex.sh
	              curl -s -o odex.sh $zjw2017_latesturl
                  if [ $? -eq 0 ]; then
                     echo "- 新版本已下载完毕，请退出重新运行odex.sh"
                     rm -rf version_DavidPisces
			         rm -rf version_zjw2017
                     exit
        		     else
		             echo "! 下载失败"
			         rm -rf version_DavidPisces
			         rm -rf version_zjw2017
                  fi
	           else
	              echo "已取消"
		          rm -rf version_DavidPisces
			      rm -rf version_zjw2017
		          exit
	           fi
			fi 
         fi
	  fi	 
    fi
   if [ $update_method == 2 ] ; then
      clear
	  # Gitee Raw
	  echo "- 正在查询Github最新版本，请坐和放宽"
      curl -s -o version_zjw2017 https://gitee.com/yzdhz/odex-For-MIUI-WeeklyReleases/raw/master/version
	  curl -s -o version_DavidPisces https://gitee.com/David-GithubClone/MIUI-Auto-Odex/raw/master/version
	  zjw2017_latesturl="https://gitee.com/yzdhz/odex-For-MIUI-WeeklyReleases/raw/master/odex.sh"
	  DavidPisces_latesturl="https://gitee.com/David-GithubClone/MIUI-Auto-Odex/raw/master/odex.sh"
	  DavidPisces=$(cat version_DavidPisces)
	  zjw2017=$(cat version_zjw2017)
	  DavidPisces_New=$(echo "$DavidPisces > $zjw2017" | bc) 
	  zjw2017_New=$(echo "$zjw2017 > $DavidPisces" | bc)
	  if [ $zjw2017 == $DavidPisces ] ; then
         echo "- 未发现新版本"
	     echo "  zjw2017当前版本：$zjw2017"
	     echo "  DavidPisces当前版本：$DavidPisces"
	     echo "  是否重新下载？"
	     echo "  [y] 下载"
	     echo "  [n] 取消"
		 echo -e "\n请输入选项"
	     read redownload
	     if [ $redownload == "y" ] ;then
	        clear
			echo "- 正在下载更新，请坐和放宽"
			rm -rf odex.sh
	        curl -s -o odex.sh $zjw2017_latesturl
            if [ $? -eq 0 ]; then
               echo "- 下载完毕，请退出重新运行odex.sh"
               rm -rf version_DavidPisces
			   rm -rf version_zjw2017
               exit
		    else
		       echo "! 下载失败"
			   rm -rf version_DavidPisces
			   rm -rf version_zjw2017
            fi
	     else
		    echo "# 已取消"
		    rm -rf version_DavidPisces
			rm -rf version_zjw2017
		    exit
	     fi	
	  else
	     if [ $DavidPisces_New = 1 ] ; then
            echo "! 发现新版本$DavidPisces，是否更新"
	        echo "  [y] 更新"
	        echo "  [n] 取消"
		    echo -e "\n请输入选项"
	        read update_choice
	        if [ $update_choice == "y" ] ;then
	           clear
		       echo "- 正在下载更新，请坐和放宽"
		       rm -rf odex.sh
	           curl -s -o odex.sh $DavidPisces_latesturl
               if [ $? -eq 0 ]; then
                  echo "- 新版本已下载完毕，请退出重新运行odex.sh"
                  rm -rf version
                  exit
		       else
		          echo "! 下载失败"
			      rm -rf version_DavidPisces
			      rm -rf version_zjw2017
               fi
	        else
	           echo "已取消"
		       rm -rf version_DavidPisces
			   rm -rf version_zjw2017
		       exit
	        fi
         else
		    if [ $zjw2017_New = 1 ] ; then
               echo "! 发现新版本$zjw2017，是否更新"
	           echo "  [y] 更新"
	           echo "  [n] 取消"
		       echo -e "\n请输入选项"
	           read update_choice
	           if [ $update_choice == "y" ] ;then
	              clear
		          echo "- 正在下载更新，请坐和放宽"
		          rm -rf odex.sh
	              curl -s -o odex.sh $zjw2017_latesturl
                  if [ $? -eq 0 ]; then
                     echo "- 新版本已下载完毕，请退出重新运行odex.sh"
                     rm -rf version_DavidPisces
			         rm -rf version_zjw2017
                     exit
        		     else
		             echo "! 下载失败"
			         rm -rf version
                  fi
	           else
	              echo "已取消"
		          rm -rf version_DavidPisces
			      rm -rf version_zjw2017
		          exit
	           fi
			fi 
         fi
	  fi	 
    fi
fi
