#!/system/bin/sh
echo "===SuSSR v5.3==="
echo "===by supppig==="
echo ""
getbackstring()
{
[ -z "$ss" ] && str=$($1) || str=$ss && ss=""
f="0" && re=""
for x in $str
do
 if [ "$f" = "0" ];then
  f="0" && [ "$x" = "$2" ] && f="1"
 else
  ff="1" && for xx in $3;do [ $x = $xx ] && ff="0";done
  if [ "$ff" = "1" ];then
  [ -z "$re" ] && re=$x || re=$re" "$x
  fi
  f="0"
 fi
done
[ -z "$re" ] && re=$4
}
findstring()
{
iptables -t $1 | ${bgrep} -q "$2" && re="$3" || re="$4"
[ "$5" = "y" ] && echo "$re"
}
findstringbyss()
{
if [ "$ss" = "" ];then
re="$2"
reb="n"
else
re="$1"
reb="y"
fi
ss=""
[ "$3" = "y" ] && echo "$re"
[ "$3" = "yn" ] && echo -n "$re"
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
cd $DIR
workdir=${DIR}'/tools'
kpdir=${workdir}'/KoolProxy'
bbx=${DIR}'/tools/busybox'
cbbx grep
cbbx cut
cbbx ps
cbbx ifconfig
. ./setting.ini
if [ "$vpsconf" != "" ];then
if [ -s $DIR/VPS/$vpsconf.txt ];then
. $DIR/VPS/$vpsconf.txt
elif [ -s $DIR/VPS/$vpsconf ];then
. $DIR/VPS/$vpsconf
else
echo "配置文件$vpsconf不存在！配置文件必须是无后缀或者.txt后缀。
例如vps配置文件写的是“香港”，则VPS文件夹下，应该存着文件“香港”或者“香港.txt”！
请检查后重新开启脚本。"
exit 1
fi
else
vpsconf="内置配置"
fi
[ "$label" != "" ] && echo "配置文件：$vpsconf($label)" || echo "配置文件：$vpsconf"
if [ "$pbq" = "1" ];then
${bps} | ${bgrep} '/ss-redir-video' | ${bgrep} -vq grep && echo -n "✔ss-redir(破版权) "||echo -n "✘ss-redir(破版权) "
else
${bps} | ${bgrep} '/ss-redir' | ${bgrep} -vq grep && echo -n "✔ss-redir "||echo -n "✘ss-redir"
fi
if [ "$dns" != "0" ];then
${bps} | ${bgrep} '/pdnsd' | ${bgrep} -vq grep && echo "✔pdnsd  "||echo "✘pdnsd"
else
echo "(DNS直连)"
fi
ss=$(iptables -t mangle -S SSR_UDP_PRE | ${bgrep} 'on-port' | ${bgrep} 1250)
findstringbyss "y" "n"
if [ "$re" = "y" ];then
${bps} | ${bgrep} '/redsocks2' | ${bgrep} -vq grep && echo -n "✔redsocks2  "||echo -n "✘redsocks2  "
${bps} | ${bgrep} '/gost' | ${bgrep} -vq grep && echo -n "✔gost  "||echo -n "✘gost  "
${bps} | ${bgrep} '/ss-local' | ${bgrep} -vq grep && echo "✔ss-local"||echo "✘ss-local"
fi
echo ""
if [ "$jxjg" != "" ];then
echo "=====域名转IP====="
echo -e "$jxjg"
fi
echo "===iptables链检测==="
findstring "nat -S PREROUTING" "ssr_nat_PRE" "✔nat_PRE" "✘nat_PRE"
allre=$re
findstring "nat -S OUTPUT" "ssr_nat_OUT" "✔nat_OUT" "✘nat_OUT"
allre=$allre" "$re
echo "nat表: "$allre
if [ "$dludp" = "1" -o "$dludp" = "2" ];then
findstring "mangle -S SSR_UDP_PRE" "SSR_UDP_LAN" "✔UDP_LAN" "✘UDP_LAN"
allre=$re
findstring "mangle -S PREROUTING" "SSR_UDP_PRE" "✔UDP_PRE" "✘UDP_PRE"
allre=$allre" "$re
findstring "mangle -S OUTPUT" "SSR_UDP_OUT" "✔UDP_OUT" "✘UDP_OUT"
allre=$allre" "$re
echo "mangle表: "$allre
fi
echo ""
findstring "nat -S ssr_nat_OUT" "ACCEPT" "y" "n"
if [ "$re" = "y" ];then
if [ "$dataadb" = "1" -o "$wifiadb" = "1" -o "$hotadb" != "0" ];then
echo "=====广告过滤====="
${bps} | ${bgrep} '/koolproxy' | ${bgrep} -vq grep && echo "插件：✔kooolproxy  "||echo "插件：✘koolproxy  "
${bps} | ${bgrep} '/koolproxy' | ${bgrep} -vq grep && kprunning="y" || kprunning="n"
if [ "$kprunning" = "y" ];then
echo -n "过滤范围："
ss=$(iptables -t nat -S ssr_nat_OUT | ${bgrep} 'ad_block' | ${bgrep} -v wlan)
findstringbyss "✔" "✘"
echo -n "$re数据  "
dataadb_c=$reb
x=$(iptables -t nat -S ssr_nat_OUT | ${bgrep} -oE 'ad_block|wlan' -m1)
if  [ "$x" = "wlan" ];then
echo -n "✘WiFi  "
wifiadb_c="n"
else
echo -n "✔WiFi  "
wifiadb_c="y"
fi
ss=$(iptables -t nat -S ssr_nat_PRE | ${bgrep} '8080' | ${bgrep} '3000')
findstringbyss "✔" "✘"
echo "$re热点"
if [ "${dataadb_c}${wifiadb_c}" != "nn" ];then
ss=$(iptables -t nat -S ad_block | ${bgrep} tcp | ${bgrep} -v uid | ${bgrep} 3000)
findstringbyss "└过滤模式：全局过滤" "└过滤模式：过滤指定应用" "y"
[ "$reb" = "y" ] && pstr="└不过滤应用：" || pstr="└过滤应用："
[ "$reb" = "y" ] && x="" || x="未设置(设置不合理)"
ss=$(iptables -t nat -S ad_block | ${bgrep} uid)
getbackstring "" "--uid-owner" "0-9999" "$x"
if [ "$re" != "" ];then
echo "${pstr}${re}"
fi
if [ "$wifiadb_c" = "y" ];then
ss=$(iptables -t nat -S ad_block)
getbackstring "" "-s" "" ""
if [ "$re" != "" ];then
echo "└WiFi放行白名单："$re
fi
fi
fi
str=$(${bgrep} '^!x.*video' -m1 $kpdir/koolproxy.txt | ${bgrep} -o '20[0-9\|-]\{6,8\}\ \([0-9]\)\{1,2\}:[0-9]\{1,2\}')
[ "$str" != "" ] && echo "视频规则更新日期：$str"
str=$(${bgrep} '^!x.*rules' -m1 $kpdir/koolproxy.txt | ${bgrep} -o '20[0-9\|-]\{6,8\}\ \([0-9]\)\{1,2\}:[0-9]\{1,2\}')
[ "$str" != "" ] && echo "静态规则更新日期：$str"
str=$(${bgrep} '^!.*update' -m1 $kpdir/add_rules.txt | ${bgrep} -o '20[0-9\|-]\{6,8\}\ \([0-9]\)\{1,2\}:[0-9]\{1,2\}')
[ "$str" != "" ] && echo "每日规则更新日期：$str"
[ "$kpupstr" != "" ] && echo -e $kpupstr
fi
echo ""
fi
echo "====UDP转发设置===="
ss=$(iptables -t nat -S ssr_nat_OUT | ${bgrep} udp | ${bgrep} 65535 | ${bgrep} -v owner)
findstringbyss "本机UDP：✘ 禁网" "本机UDP：✔ 联网" "y"
ss=$(iptables -t nat -S ssr_nat_PRE | ${bgrep} udp | ${bgrep} 65535)
findstringbyss "热点UDP：✘ 禁网" "热点UDP：✔ 联网" "y"
getbackstring "iptables -t mangle -S SSR_UDP_PRE" "--on-port" "" "888"
case $re in
888)
 echo "UDP代理方式：不转发(直连)"
 jx="n"
 ;;
1230)
 echo -n "UDP代理方式：UDP转发"
 ;;
1231)
 echo -n "UDP代理方式：UDP转发(自定义端口)"
 ;;
1250)
 echo -n "UDP代理方式：通过TCP转发"
 ;;
*)
 echo "UDP代理方式：检测失败！"
 jx="n"
 ;;
esac
if [ "$jx" != "n" ];then
ss=$(iptables -t mangle -S SSR_UDP_OUT | ${bgrep} -v owner | ${bgrep} 6688)
findstringbyss "（全局）" "（局部）" "y"
if [ "$reb" = "n" ];then
ss=$(iptables -t mangle -S SSR_UDP_OUT | ${bgrep} owner | ${bgrep} 6688)
getbackstring "" "--uid-owner" "0 3004" "未设置(设置不合理)"
echo "代理UDP应用：$re"
else
ss=$(iptables -t mangle -S SSR_UDP_OUT | ${bgrep} owner | ${bgrep} ACCEPT)
getbackstring "" "--uid-owner" "0 3004" ""
[ "$re" != "" ] && echo "不代理UDP应用：$re"
fi
fi
echo ""
ss=$(iptables -t nat -S ssr_nat_OUT | ${bgrep} tcp | ${bgrep} ACCEPT)
getbackstring "" "--uid-owner" "" ""
cftcp="$re"
ss=$(iptables -t nat -S ssr_nat_OUT | ${bgrep} udp | ${bgrep} ACCEPT)
getbackstring "" "--uid-owner" "" ""
cudpf="$re"
ss=$(iptables -t nat -S ssr_nat_OUT | ${bgrep} udp | ${bgrep} 65535)
getbackstring "" "--uid-owner" "" ""
cudpj="$re"
if [ "$cftcp$cudpf$cudpj" != "" ];then
echo "====应用单独设置===="
fi
if [ "$cftcp" != "" ];then
echo "TCP放行UID：$cftcp"
fi
if [ "$cudpf" != "" ];then
echo "UDP放行UID：$cudpf"
fi
if [ "$cudpj" != "" ];then
echo "UDP禁网UID：$cudpj"
fi
if [ "$cftcp$cudpf$cudpj" != "" ];then
echo ""
fi
echo ✄┄ ┄ ┄ ┄ ┄ ┄ ┄ ┄ ┄ ┄ ┄ ┄ ┄ ┄
echo ""
echo ✺ nat表 ssr_nat_OUT链:
iptables -t nat -S ssr_nat_OUT
echo ""
echo ✺ nat表 ssr_nat_PRE链:
iptables -t nat -S ssr_nat_PRE
if [ "$dludp" = "1" -o "$dludp" = "2" ];then
echo ""
echo ✺ mangle表 SSR_UDP_LAN链:
iptables -t mangle -S SSR_UDP_LAN
echo ""
echo ✺ mangle表 SSR_UDP_OUT链:
iptables -t mangle -S SSR_UDP_OUT
echo ""
echo ✺ mangle表 SSR_UDP_PER链:
iptables -t mangle -S SSR_UDP_PRE
fi
if [ "$dataadb" = "1" -o "$wifiadb" = "1" -o "$hotadb" != "0" ];then
echo ""
echo ✺ nat表 ad_block链:
iptables -t nat -S ad_block
fi
else
 echo "提示：脚本已关闭，正常情况下，以上检测结果应该全部是✘。"
fi
