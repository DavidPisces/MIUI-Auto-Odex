# MIUI ODEX

##### 一个适用于中国版MIUI自动化odex shell脚本

***

### 贡献者

冷洛 DavidPisces [[Github](https://github.com/DavidPisces)] | [[酷安](http://www.coolapk.com/u/665894)]

柚稚的孩纸 zjw2017 [[Github](https://github.com/zjw2017)] | [[酷安](http://www.coolapk.com/u/1548958)]

本仓库国内Gitee地址 [[Gitee仓库](https://gitee.com/David-GithubClone/MIUI-Auto-Odex)]

[[English version]](https://github.com/DavidPisces/MIUI-Auto-Odex/tree/English)

#### 能做什么

> 此脚本能实现系统软件的odex与用户软件dex2oat编译，适用于被MIUI官方删除odex的机型
>
> 支持Complete(完整)与Simple(简单)编译模式，Speed与Everything两种dex2oat编译模式
>
> 支持生成odex文件后自动生成Magisk模块并自动安装
>
> 支持自选编译模式

****

#### 运行环境

###### 必要

* 必须具有Root权限
* 必须使用Magisk 24.0及以上Magisk版本
* 需要使用MT管理器或者其他终端执行脚本，比如Ansole终端、Termux等

###### 建议 

* 动态适配各个Android大版本(Android P以下不保证生效)和MIUI11-MIUI13
* 建议安装完整Busybox

#### 执行错误

* 如果你在初始化时遇到“syntax error”或者"inaccessible or not found"等错误，请执行[dos2unix]命令来去除文件中的^M，因为Windows系统编辑会将换行表示为^M符号，如果你遇到脚本执行直接报错，可以先使用[cat]命令来检查脚本内是否含有“^M”符号，再决定使用[dos2unix]命令来转换。
* dos2unix用法：dos2unix filename   (例如：dos2unix odex.sh)
* 使用cat获取文件内容：cat filename   (例如：cat odex.sh)

#### 如何使用
* 1、Magisk

  >安装模块：odex_script_update_online.zip
  >

* 2-1 MT管理器

  >进入/storage/emulated/0/Android/MIUI_odex，根据需要编辑Simple_List.prop文件
  >
  >执行odex.sh并勾选左侧Root
  >
  >![](http://image.coolapk.com/feed/2020/0623/15/665894_f922a721_8810_5677@1080x2160.jpeg.m.jpg)

* 2-2 其他终端

  > su
  >
  > cd /storage/emulated/0/Android/MIUI_odex
  >
  > bash odex.sh
  >
  >![](http://image.coolapk.com/feed/2020/0623/15/665894_16498409_8810_5679@1080x2160.jpeg.m.jpg)
