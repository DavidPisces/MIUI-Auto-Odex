# MIUI ODEX

##### A shell script to process ODEX for MIUI

***

### Contributors

DavidPisces [[Github](https://github.com/DavidPisces)] | [[Coolapk](http://www.coolapk.com/u/665894)]

zjw2017 [[Github](https://github.com/zjw2017)] | [[Coolapk](http://www.coolapk.com/u/154895[[8)]

[[Chinese version]](https://github.com/DavidPisces/MIUI-Auto-Odex/tree/master)

#### What can it doos

> This software can compile ODEX and odex2oat of the system software, and is applicable to the models that have been officially deleted by MIUI
>
> Support complete and simple compilation modes, and speed and everything two dex2oat compilation modes
>
> It supports automatic generation and installation of magisk modules after generating ODEX files
>
> Support optional compilation mode
>
> Support for online updates (downloaded from GitHub)

****

#### Environment

###### Necessary

* Root
* A terminal simulator that can execute scripts

###### Suggestions

* Miui11-12 based on Android 10 is recommended
* Magisk version 20.4 and above is recommended
* It is recommended to install the full busybox

#### Execution error

* If you encounter "syntax error" or "inaccessible or not found" errors during initialization, please execute the [dos2unix] command to remove the ^ m in the file, because the windows system editor will represent the line break as the ^ m symbol. If you encounter a direct error in the execution of the script, you can first use the [cat] command to check whether the script contains the "^ m" symbol, Then decided to use the [dos2unix] command to convert.
* Dos2unix usage: dos2unix filename (for example: dos2unix ODEX. SH)
* Use cat to get the file content: cat filename (for example: cat ODEX. SH)

#### How to use

* Terminal
  > su
  >
  > cd directory
  >
  > sh odex.sh
  >
  >![](http://image.coolapk.com/feed/2020/0623/15/665894_16498409_8810_5679@1080x2160.jpeg.m.jpg)
