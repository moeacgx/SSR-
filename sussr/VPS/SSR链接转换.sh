#!/system/bin/sh
makeconf()
{
a=$(echo -n $1 | ${bcut} -d'/' -f3 | ${bsed} s#'_'#'/'#)
allstr=$(echo -n $a | ${bbase64} -d 2>&-)
ip='';port='';protocol='';method='';obfs='';password=''
host='';protocol_param='';remarks='';group=''
fstr=$(echo -n $allstr | ${bcut} -d'/' -f1)
ip=$(echo -n $fstr | ${bcut} -d':' -f1)
port=$(echo -n $fstr | ${bcut} -d':' -f2)
protocol=$(echo -n $fstr | ${bcut} -d':' -f3)
method=$(echo -n $fstr | ${bcut} -d':' -f4)
obfs=$(echo -n $fstr | ${bcut} -d':' -f5)
password=$(echo -n $fstr | ${bcut} -d':' -f6 | ${bbase64} -d 2>&-)
if [ "$password" = "" ];then
echo "$2解析出错~~程序退出~~"
exit 1
fi
sstr=$(echo -n $allstr | ${bcut} -d'?' -f2 | ${bsed} s/'&'/';'/g)
eval $sstr
host=$(echo -n $obfsparam | ${bbase64} -d 2>&-)
protocol_param=$(echo -n $protoparam | ${bbase64} -d 2>&-)
remarks=$(echo -n $remarks | ${bbase64} -d 2>&-)
group=$(echo -n $group | ${bbase64} -d 2>&-)
timenow=$(${bdate} '+%Y-%m-%d_%H:%M:%S')
[ "$group" = "" ] && label=$remarks || label=$group'-'$remarks
[ "$label" = "" ] && label='自动转换'$timenow
${bcat} > $2 <<SUPPPIG
#$label
#生成日期：$timenow
#配置自动生成 by supppig
#SSR配置
label='$label'
ip='$ip' #SSR的IP
port='$port' #SSR端口
password='$password' #密码
method='$method' #加密方式
protocol='$protocol' #协议
protocol_param='$protocol_param' #协议参数
obfs='$obfs' #混淆
${fghost}host='$host' #混淆参数，最前面有#号则不起效。
#↓DNS地址(无#开头为启用的dns)
$strdns
#dns='114.114.114.114'
#dns='8.8.8.8'
#↓gost服务器地址(留空用SSR服务器IP)
gostip=''
#↓服务器的gost密码
gostpwd='supppig'
#↓服务器udp端口/gost端口
udpport=''
#如果需要这些选项覆盖全局设置，请删除前面的#
#↓破视频版权(0=关闭，1=开启)
$pbqstr
SUPPPIG
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
DIR="${0%/*}"
bbx=${DIR}'/../tools/busybox'
cbbx ls
cbbx grep
cbbx cut
cbbx base64
cbbx sed
cbbx cat
cbbx head
cbbx date
cbbx rm
cd $DIR
echo "SSR链接转换程序 v1.0"
echo "    by supppig
"
echo "正在读取配置文件。。。
==>>>"
. ./转换配置.ini
if [ "$usehost" = "1" ];then
echo "使用SSR链接中的host！"
fghost=''
else
echo "使用setting.ini中的host。"
fghost='#'
fi
if [ "$dns" = "" ];then
echo "默认DNS未设置。dns将使用setting.ini中的dns。"
strdns=""
else
echo "读取到默认DNS为$dns"
strdns="dns=\'$dns\'"
fi
if [ "$pbq" = "1" ];then
echo "设置破版权开关打开。"
pbqstr='pbq=1'
elif [ "$pbq" = "0" ];then
echo "设置破版权开关关闭。"
pbqstr='pbq=0'
else
echo "不改变破版权开关设置。破版权开关遵循setting.ini中的配置。"
pbqstr='#pbq=0'
fi
echo "<<<==
读取配置文件完毕
"
echo "开始查找待转换文件。文件为(无后缀)或(.txt后缀)。
"
all=$(${bls})
for x in $all
do
t=$(echo $x | ${bgrep} '\.txt')
if [ "$t" = "" ];then
d=$(echo $x | ${bgrep} '\.')
[ "$d" != "" ] && continue
[ -d $x ] && continue
fi
h=$(${bhead} -1 $x | ${bgrep} '^ssr://')
[ "$h" = "" ] && continue
echo "找到待转换文件$x"
ff="y"
makeconf $h $x
echo "转换文件$x完成！
"
done
[ "$ff" != "y" ] && echo "！！！找不到可以转换的文件！！！
！！！请熟读说明再进行操作！！！
"
echo "清理re创建的bak文件
"
${brm} -f *.bak
echo "转换完成！
   by supppig"