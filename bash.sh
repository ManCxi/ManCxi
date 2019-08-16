#!/bin/bash

yum=`yum repolist | awk -F: '/repolist/{print $2}' |sed 's/,//'`
[ $yum -gt 0 ] && echo "yum源可用" || echo "yum源不可用"
rpm -q expect
if [ $? -eq 0 ];then
echo "expect 已经安装"
else
echo "expect 未安装,正在安装..."
yum -y install expect
fi

yum install -y wget 

wget -O install.sh http://download.bt.cn/install/install_6.0.sh

sh install.sh
expect <<oppo
set timeout 10
expect "Do you want to install Bt-Panel to the /www directory now?(y/n):"       {send "y\r"}
oppo

if [ $? -eq 0];then

    rm -f /www/server/panel/data/admin_path.pl

    cd /www/server/panel && python tools.py panel 123456

    btuser=`cd /www/server/panel && python tools.py panel 123456`

    btpass=123456
    
    echo "宝塔面板地址：http://ip地址:8888
    用户名:$btuser
    密码：$btpass"
    
    else
    
    echo "宝塔安装失败"

fi
