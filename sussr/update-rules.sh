#!/system/bin/sh
 
################
#KP规则更新脚本#
#  by supppig  #
################
 
wgetdown()
{
output=$1
url1=$2
${brm} -f $output
${bwget} -q -T10 -O $output $url1
if [ "$?" != "0" ] || [ ! -s "$output" ] ; then
	${brm} -f $output
fi
if [ -s "$output" ] ; then
    ${bchmod} 777 $output
fi
}
checkdownload()
{
if [ ! -s "$predown/$1" ];then
${brm} -rf $predown
echo "$2规则下载失败！退出！"
exit 1
fi
}
md5update()
{
old_md5=`${bmd5sum} $kpdir/$1 | ${bcut} -d' ' -f1`
new_md5=`${bmd5sum} $predown/$1 | ${bcut} -d' ' -f1`
old_md5=${old_md5:0:6}
new_md5=${new_md5:0:6}
if [ "$old_md5" != "$new_md5" ] ; then
echo "$2规则有更新！($old_md5-->$new_md5)"
eval $3'=y'
else
echo "$2规则没有更新($old_md5)"
fi
}
replace()
{
if [ "$3" = "y" ];then
echo "正在替换$2规则文件。。。"
${brm} -f "$kpdir/$1"
${bcp} -f "$predown/$1" "$kpdir/$1"
fi
}
printkpinfo()
{
str=$(${bgrep} '^!x.*video' -m1 $kpdir/koolproxy.txt | ${bgrep} -o '20[0-9\|-]\{6,8\}\ \([0-9]\)\{1,2\}:[0-9]\{1,2\}')
echo "视频规则更新日期：$str"
str=$(${bgrep} '^!x.*rules' -m1 $kpdir/koolproxy.txt | ${bgrep} -o '20[0-9\|-]\{6,8\}\ \([0-9]\)\{1,2\}:[0-9]\{1,2\}')
echo "静态规则更新日期：$str"
str=$(${bgrep} '^!x.*Thanks' -m1 $kpdir/koolproxy.txt | ${bgrep} -o '<.*>')
[ "$str" != "" ] && echo "  └规则作者：$str"
str=$(${bgrep} '^!.*update' -m1 $kpdir/add_rules.txt | ${bgrep} -o '20[0-9\|-]\{6,8\}\ \([0-9]\)\{1,2\}:[0-9]\{1,2\}')
echo "每日规则更新日期：$str"
str=$(${bgrep} '^!.*Thanks' -m1 $kpdir/add_rules.txt | ${bgrep} -o '<.*>')
[ "$str" != "" ] && echo "  └规则作者：$str"
}
killkp()
{
echo "关闭KoolProxy
"
${bkillall} -q koolproxy
}
cbbx()
{
type $1 2>&- >&-
if [ "$?" = "0" ];then
eval b$1=$1
else
eval b$1=\"$bbx $1\"
fi
}
automount()
{
echo "supppig" >$1/test.supppig
if [ "$?" = "0" ];then
${brm} -f $1/test.supppig
else
x=$(echo $1 | ${bcut} -d'/' -f2)
${bmount} -o rw,remount /$x 2>&- || ${bmount} -o remount,rw /$x 2>&-
fi
}
echo "
==KoolProxy规则更新脚本==
=====  by supppig  ====
"
DIR="${0%/*}"
workdir=${DIR}'/tools'
kpdir=${workdir}'/KoolProxy'
bbx=${DIR}'/tools/busybox'
cbbx grep
cbbx cut
cbbx md5sum
cbbx rm
cbbx cp
cbbx wget
cbbx chmod
cbbx killall
cbbx date
cbbx mkdir
cbbx mount
predown=$workdir/pre_download
if [ "$1" = "a" ];then
sleep 30
fi
automount $kpdir
cd $DIR
${brm} -rf $predown
${bmkdir} $predown
spurl="http://entware.mirrors.ligux.com/koolproxy/1.dat"
jturl="http://entware.mirrors.ligux.com/koolproxy/koolproxy.txt"
mrurl="http://entware.mirrors.ligux.com/koolproxy/add_rules.txt"
echo "下载规则。。。
"
wgetdown "$predown/add_rules.txt" $mrurl
checkdownload "add_rules.txt" "每日"
wgetdown "$predown/1.dat" $spurl
checkdownload "1.dat" "视频"
wgetdown "$predown/koolproxy.txt" $jturl
checkdownload "koolproxy.txt" "静态"
echo "启动md5校检更新模式。。。"
echo ""
md5update "koolproxy.txt" "静态" "jtgx"
md5update "1.dat" "视频" "spgx"
md5update "add_rules.txt" "每日" "mrgx"
echo ""
newtime=$(${bdate} +%s)
echo "#上次检查更新时间：$x
oldtime=$newtime" >$kpdir/supppig
if [ "$jtgx$spgx$mrgx" = "" ];then
printkpinfo
echo "
KoolProxy规则不需更新。程序退出。"
${brm} -rf $predown
exit 0
fi
killkp
replace "koolproxy.txt" "静态" "$jtgx"
replace "1.dat" "视频" "$spgx"
replace "add_rules.txt" "每日" "$mrgx"
echo "
重启KoolProxy
"
$kpdir/koolproxy -c2 -b $kpdir -d >/dev/null &
printkpinfo
${brm} -rf $predown
echo "
KoolProxy更新完毕！"
exit 0
