#!/system/bin/sh
 
############
#  SuSSR   #
#  ver5.3  #
#By supppig#
############
 
##脚本部分全部开源，禁止用于商业用途，否则后果自负！##
 
addiptables()
{
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 2 > /proc/sys/net/ipv4/conf/default/rp_filter
echo 2 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 1 > /proc/sys/net/ipv4/conf/all/send_redirects
if [ "$gxzfms" = "2" ];then
gxzf="DNAT --to-destination $gxwgip:"
else
gxzf="REDIRECT --to-ports "
fi
if [ "$bdzfms" = "2" ];then
bdzf="DNAT --to-destination 127.0.0.1:"
else
bdzf="REDIRECT --to-ports "
fi
if [ "$dataadb" = "1" -o "$wifiadb" = "1" ];then
iptables -t nat -N ad_block
sleep 0.1
if [ "$bjglms" = "1" ];then
adzfuid="${bdzf}3000"
adzfall="RETURN"
else
adzfuid="RETURN"
adzfall="${bdzf}3000"
fi
if [ "$wifiadb" = "1" -a "$wifinoadb" != "" ];then
for x in "$wifinoadb"
do
if [ "$x" != "" ];then iptables -t nat -A ad_block -o wlan+ -s $x -j RETURN;fi
done
fi
iptables -t nat -A ad_block -m owner --uid-owner 0-9999 -j RETURN
if [ "$adlwuid" != "" ];then  
for x in "$adlwuid"
do
if [ "$x" != "" ];then iptables -t nat -A ad_block -p tcp -m owner --uid-owner $x -j ${adzfuid};fi
done
fi
iptables -t nat -A ad_block -p tcp -j ${adzfall}
fi
iptables -t nat -N ssr_nat_OUT
sleep 0.1
iptables -t nat -A ssr_nat_OUT ${ssfx} -j ACCEPT
iptables -t nat -A ssr_nat_OUT -o lo -j ACCEPT
iptables -t nat -A ssr_nat_OUT -o tun+ -j ACCEPT
iptables -t nat -A ssr_nat_OUT -o ap+ -j ACCEPT
for x in $tfx;   
do
  if [ "$x" != "" ];then iptables -t nat -A ssr_nat_OUT -p tcp -m owner --uid-owner $x -j ACCEPT;fi
done
if [ "$cxfx" = "1" ];then
iptables -t nat -A ssr_nat_OUT -d 10.0.0.172/32 -j ACCEPT 
elif [ "$cxfx" = "2" ];then
iptables -t nat -A ssr_nat_OUT -d 10.0.0.200/32 -j ACCEPT
fi
if [ "$dataadb" = "0" -a "$wifiadb" = "1" ];then
x='-o wlan+'
else
x=''
fi
if [ "$dataadb" = "1" -o "$wifiadb" = "1" ];then
iptables -t nat -A ssr_nat_OUT $x -p tcp -m multiport --dports 80,8080 -j ad_block
if [ "$?" != "0" ];then
iptables -t nat -A ssr_nat_OUT $x -p tcp --dport 80 -j ad_block
iptables -t nat -A ssr_nat_OUT $x -p tcp --dport 8080 -j ad_block
fi
fi
[ "$wifiadb" = "1" ] && wifiaddrule='-A ssr_nat_OUT' || wifiaddrule='-I ssr_nat_OUT 3'
if [ "$qjdl" != "1" ];then
iptables -t nat ${wifiaddrule} -o wlan+ -j ACCEPT
else
iptables -t nat ${wifiaddrule} -p udp --dport 67:68 -j ACCEPT
iptables -t nat ${wifiaddrule} -d 224.0.0.0/3 -j ACCEPT
fi
iptables -t nat -A ssr_nat_OUT -p tcp -j ${bdzf}1230
for x in $ufx;   
do
  if [ "$x" != "" ];then iptables -t nat -A ssr_nat_OUT -p udp -m owner --uid-owner $x -j ACCEPT;fi
done
for x in $ujw;   
do
  if [ "$x" != "" ];then iptables -t nat -A ssr_nat_OUT -p udp -m owner --uid-owner $x -j ${bdzf}65535;fi
done
if [ "$dns" != "0" ];then
iptables -t nat -A ssr_nat_OUT -p udp --dport 53 -j ${bdzf}1240
else
iptables -t nat -A ssr_nat_OUT -p udp --dport 53 -j ACCEPT
fi
if [ "$bjudp" = "0" ];then
  iptables -t nat -A ssr_nat_OUT -p udp -j ${bdzf}65535
else
  iptables -t nat -A ssr_nat_OUT -p udp -j ACCEPT
fi
iptables -t nat -I OUTPUT -j ssr_nat_OUT
sleep 0.1
iptables -t nat -N ssr_nat_PRE
sleep 0.1
iptables -t nat -A ssr_nat_PRE ! -s 192.168.0.0/16 -j ACCEPT
iptables -t nat -A ssr_nat_PRE -d 192.168.0.0/16 -j ACCEPT
if [ "$hotadb" != "0" ];then
iptables -t nat -A ssr_nat_PRE -p tcp -m multiport --dports 80,8080 -j ${gxzf}3000 
if [ "$?" != "0" ];then
iptables -t nat -A ssr_nat_PRE -p tcp --dport 80 -j ${gxzf}3000
iptables -t nat -A ssr_nat_PRE -p tcp --dport 8080 -j ${gxzf}3000
fi
fi
iptables -t nat -A ssr_nat_PRE -p tcp -j ${gxzf}1230
if [ "$dns" != "0" ];then
iptables -t nat -A ssr_nat_PRE -p udp --dport 53 -j ${gxzf}1240
else
iptables -t nat -A ssr_nat_PRE -p udp --dport 53 -j ACCEPT
fi
if [ "$gxudp" = "0" ];then
iptables -t nat -A ssr_nat_PRE -p udp -j ${gxzf}65535
else
iptables -t nat -A ssr_nat_PRE -p udp -j ACCEPT
fi
iptables -t nat -I PREROUTING -j ssr_nat_PRE
sleep 0.1
if [ "$dludp" = "1" -o "$dludp" = "2" ];then
iptables -t mangle -N SSR_UDP_LAN
sleep 0.1
iptables -t mangle -A SSR_UDP_LAN -d 127.0.0.0/8 -j ACCEPT 
iptables -t mangle -A SSR_UDP_LAN -d 192.168.0.0/16 -j ACCEPT
iptables -t mangle -A SSR_UDP_LAN -d 10.0.0.0/8 -j ACCEPT
iptables -t mangle -A SSR_UDP_LAN -d $ip -j ACCEPT
iptables -t mangle -A SSR_UDP_LAN -d 224.0.0.0/3 -j ACCEPT
iptables -t mangle -A SSR_UDP_LAN -d 0.0.0.0/8 -j ACCEPT
iptables -t mangle -A SSR_UDP_LAN -d 172.16.0.0/12 -j ACCEPT
iptables -t mangle -A SSR_UDP_LAN -d 100.64.0.0/10 -j ACCEPT
iptables -t mangle -A SSR_UDP_LAN -d 169.254.0.0/16 -j ACCEPT
iptables -t mangle -N SSR_UDP_PRE 
sleep 0.1
iptables -t mangle -A SSR_UDP_PRE -j SSR_UDP_LAN
iptables -t mangle -A SSR_UDP_PRE -p udp -j TPROXY --on-port ${zfudpport} --tproxy-mark 0x6688
if [ "$?" != "0" ];then
killprocess
deliptables
${brm} -f *.conf
echo ""
echo "唉。。呃。。。这应该怎么说好呢。。:("
echo ""
echo "你的手机系统，貌似不支持TPROXY模块啊~~~"
echo "所以嘛。。UDP转发就不支持啦~~~"
echo "把setting.ini里面的“UDP代理方式”改成0，再启动吧~"
echo "  脚本版免UDP，是没戏了~~~"
echo ""
exit 1
fi
iptables -t mangle -I PREROUTING -p udp -j SSR_UDP_PRE
sleep 0.1
iptables -t mangle -N SSR_UDP_OUT
sleep 0.2
iptables -t mangle -A SSR_UDP_OUT ${ssfx} -j ACCEPT
iptables -t mangle -A SSR_UDP_OUT -j SSR_UDP_LAN
if [ "$qjdl" != "1" ];then
iptables -t mangle -A SSR_UDP_OUT -o wlan+ -j ACCEPT
fi
for x in $udplwuid;   
do
if [ "$x" != "" ];then
if [ "$udpdlgz" = "0" ];then 
iptables -t mangle -A SSR_UDP_OUT -m owner --uid-owner $x -j ACCEPT
else
iptables -t mangle -A SSR_UDP_OUT -m owner --uid-owner $x -j MARK --set-mark 0x6688
fi
fi
done
iptables -t mangle -A SSR_UDP_OUT -p udp --dport 53 -j ACCEPT
if [ "$udpdlgz" = "0" ];then
iptables -t mangle -A SSR_UDP_OUT -p udp -j MARK --set-mark 0x6688
else
iptables -t mangle -A SSR_UDP_OUT -j ACCEPT
fi
iptables -t mangle -I OUTPUT -p udp -j SSR_UDP_OUT
sleep 0.1
${bip} rule add fwmark 0x6688 table 251
${bip} route add local 0.0.0.0/0 dev lo table 251
sleep 0.1
fi
}
deliptables()
{
iptables -t nat -D PREROUTING -j ssr_nat_PRE 2>&-
iptables -t nat -D OUTPUT -j ssr_nat_OUT 2>&-
sleep 0.1
iptables -t nat -F ssr_nat_PRE 2>&-
iptables -t nat -F ssr_nat_OUT 2>&-
iptables -t nat -F ad_block 2>&-
iptables -t nat -X ssr_nat_PRE 2>&-
iptables -t nat -X ssr_nat_OUT 2>&-
iptables -t nat -X ad_block 2>&-
iptables -t mangle -D PREROUTING -p udp -j SSR_UDP_PRE 2>&-
iptables -t mangle -D OUTPUT -p udp -j SSR_UDP_OUT 2>&-
sleep 0.1
iptables -t mangle -F SSR_UDP_PRE 2>&-
iptables -t mangle -F SSR_UDP_OUT 2>&-
iptables -t mangle -F SSR_UDP_LAN 2>&-
iptables -t mangle -X SSR_UDP_PRE 2>&-
iptables -t mangle -X SSR_UDP_OUT 2>&-
iptables -t mangle -X SSR_UDP_LAN 2>&-
sleep 0.1
${bip} rule del fwmark 0x6688 table 251 2>&-
${bip} route del local 0.0.0.0/0 dev lo table 251 2>&-
sleep 0.1
}
killprocess()
{
allapp='ss-local pdnsd redsocks ss-redir ss-redir-video gost koolproxy update-rules.sh'
for i in $allapp
do
	${bkillall} -q $i
done
}
getvpsip_ping()
{
isip=$(echo $ip | ${bgrep} '[a-z]')
if [ "$isip" != "" ];then
isip=$(${bping} -c1 -w1 -W1 $ip | ${bgrep} 'PING' | ${bcut} -d'(' -f2 |  ${bcut} -d')' -f1)
checkip=$(echo "$isip" | ${bgrep} '\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}')
if [ "$isip" != "" -a "$isip" = "$checkip" ];then
ip=$isip
jxjg="ping解析IP地址：$ip\n"
else
jxjg="ping解析IP失败！($isip)\n"
fi
fi
}
getvpsip_wget()
{
isip=$(echo $ip | ${bgrep} '[a-z]')
if [ "$isip" != "" ];then
isip=$(${bwget} -q -T2 -O- http://119.29.29.29/d?dn=$ip | ${bcut} -d';' -f1)
checkip=$(echo "$isip" | ${bgrep} '\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}')
if [ "$isip" != "" -a "$isip" = "$checkip" ];then
ip=$isip
jxjg=$jxjg"wget解析IP地址：$ip\n"
else
jxjg=$jxjg"wget解析IP失败！($isip)\n"
fi
fi
}
make_pdnsd_conf()
{
${brm} -f ${workdir}/pdnsd.cache
${bcp} -f ${workdir}/pdnsd.supppig ${workdir}/pdnsd.cache
echo "global {
perm_cache=2048;
cache_dir=\"$workdir\";
server_ip=0.0.0.0;
server_port=1240;
query_method=tcp_only;
tcp_qtimeout=20;
timeout=20;
min_ttl=10800;
max_ttl=86400;
daemon=on;
debug=off;
verbosity=0;
neg_rrs_pol=on;
run_as=root;
}
rr {
name=localhost;
reverse=on;
a=127.0.0.1;
owner=localhost;
soa=localhost,root.localhost,42,86400,900,86400,86400;
}">${workdir}/pdnsd.conf
if [ "$dqhost" = "1" ];then
echo "source { 
owner=localhost; 
file=\"/etc/hosts\"; 
} " >>${workdir}/pdnsd.conf
fi
ll=0
for x in $dns; 
do
 if [ "$x" != "" ];then
 ((ll++))
 echo "server {
label=\"supppig$ll\";
ip=$x;
port=53;
uptest=none;
edns_query=off;
proxy_only=on;
}" >>${workdir}/pdnsd.conf
 fi
done
}
make_ssconf()
{
echo "{
\"server\": \"$ip\", 
\"server_port\": $1,
\"password\": \"$password\", 
\"method\":\"$method\", 
\"protocol\": \"$protocol\", 
\"protocol_param\": \"$protocol_param\",
\"obfs\": \"$obfs\", 
\"obfs_param\": \"$host\"
}" > ${workdir}/$2
}
make_redsocks()
{
echo "
base {
 log_debug = off;
 log_info = off;
 log = stderr;
 daemon = on;
 redirector = iptables;
}
redudp {
 local_ip = 0.0.0.0;
 local_port = 1250;
 ip = 127.0.0.1;
 port = 1251;
 type = socks5;
 udp_timeout = 20;
}
">${workdir}/redsocks.conf
}
make_gost()
{
[ "$gostip" = "" ] && gostip=$ip
echo "
{
    \"ServeNodes\": [
        \"socks://127.0.0.1:1251\"
    ],
    \"ChainNodes\": [
        \"socks://127.0.0.1:1252\",
        \"socks://supppig:${gostpwd}@${gostip}:${udpport}\"
    ]
}
" >${workdir}/gost.conf
}
datacontrol()
{
if [ "$netstat" != "$1" -a "$cqwl" = "1" ];then
wifiip=$(${bifconfig} wlan0 2>&- | ${bgrep} 'inet addr')
if [ "$wifiip" = "" ];then
[ "$1" = "y" ] && sleep 0.3 && svc data enable
[ "$1" = "n" ] && svc data disable && sleep 0.3
netstat="$1"
fi
fi
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
kpautoupdate()
{
if [ "$dataadb" = "1" -o "$wifiadb" = "1" -o "$hotadb" != "0" ] && [ "$autoupdate" = "1" ];then
oldtime=0
if [ -s ${kpdir}/supppig ];then
. ${kpdir}/supppig
let oldtimefix=oldtime+28800
lastupdatetime=$(${bdate} '+%Y-%m-%d %H:%M' -d@$oldtimefix)
else
lastupdatetime="从未更新"
fi
newtime=$(${bdate} +%s)
timex=$((newtime-oldtime))
if [ $timex -gt 21600 ];then
x=$(${bdate} '+%Y-%m-%d %H:%M')
echo "#上次检查更新时间：$x
oldtime=$newtime" >$kpdir/supppig
kpneedupdate="y"
kpupstr="上次检查更新时间为：$lastupdatetime \n└广告自动更新任务将于30秒后开始。"
else
kpneedupdate=""
kpupstr="上次检查更新时间为：$lastupdatetime \n└广告自动更新任务暂不启动。"
fi
fi
}
DIR="${0%/*}"
workdir=${DIR}'/tools'
bbx=${DIR}'/tools/busybox'
kpdir=${workdir}'/KoolProxy'
uotdir=${workdir}'/UDPoverTCP'
cbbx grep
cbbx cut
cbbx nohup
cbbx ip
cbbx killall
cbbx ping
cbbx wget
cbbx rm
cbbx cp
cbbx mount
cbbx chmod
cbbx chown
cbbx ifconfig
cbbx date
cd $DIR
if ! [ -x "$bbx" ];then
chown 0:0 $bbx
chmod 777 $bbx
if ! [ -x "$bbx" ];then
echo "权限不足。请赋予sussr文件夹及其子文件夹内所有文件777权限。"
exit 1
fi
fi
automount $workdir
${bchown} -R 0:0 $DIR
${bchmod} -R 777 $DIR
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
killprocess
deliptables
if [ "$1" = "S" ];then
exit 0
fi
sleep 0.5
if [ "$ymzh" = "1" ];then
getvpsip_ping
getvpsip_wget
fi
isip=$(echo $ip | ${bgrep} '[a-z]')
if [ "$isip" = "" ];then
datacontrol n
fi
if [ "$dludp" = "1" ];then
runas="root" && ssfx="-d $ip -m owner --uid-owner $runas"
if [ -z "$udpport" -o "$udpport" = "$port" ];then
udpport=$port sswithu="-u " zfudpport=1230
else
zfudpport=1231
fi
else
runas="net_raw" && ssfx="-d $ip -m owner --uid-owner $runas"
fi
[ "$dludp" = "2" ] && zfudpport=1250 && [ -z "$udpport" ] && udpport="6688"
hz="" && [ "$pbq" = "1" ] && hz="-video" && dns="158.69.209.100 45.32.72.192 45.63.69.42"
make_ssconf ${port} "ss.conf"
if [ "$dns" != "0" ];then
make_pdnsd_conf
fi
if [ "$dludp" = "2" ];then
make_redsocks
make_gost
sleep 1
${bnohup} ${uotdir}/ss-local -b 127.0.0.1 -l 1252 -c "${workdir}/ss.conf" -t 180 -a ${runas} >/dev/null &
${bnohup} ${uotdir}/gost -C ${workdir}/gost.conf >/dev/null &
${uotdir}/redsocks2 -c ${workdir}/redsocks.conf >/dev/null &
else
sleep 1
fi
if [ "$dataadb" = "1" -o "$wifiadb" = "1" -o "$hotadb" != "0" ];then
${kpdir}/koolproxy -c2 -b ${kpdir} -d >/dev/null &
fi
${bnohup} ${workdir}/ss-redir${hz} -b 0.0.0.0 -l 1230 -c "${workdir}/ss.conf" -t 7200 -a ${runas} ${sswithu} >/dev/null &
if [ "$dludp" = "1" -a -z "$sswithu" ];then
make_ssconf ${udpport} "ss1.conf"
${bnohup} ${workdir}/ss-redir -b 0.0.0.0 -l 1231 -c "${workdir}/ss1.conf" -t 180 -a ${runas} -U >/dev/null &
fi
if [ "$dns" != "0" ];then
${workdir}/pdnsd -c ${workdir}/pdnsd.conf >/dev/null &
fi
sleep 0.2
addiptables
${brm} -f ${workdir}/*.conf
kpautoupdate
sleep 1
cd $DIR
. ./check.sh
datacontrol n
datacontrol y
if [ "$kpneedupdate" = "y" ];then
${bnohup} ./update-rules.sh a >/dev/null &
fi
