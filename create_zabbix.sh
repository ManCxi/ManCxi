#!/bin/bash
menu(){
echo "1.安装zabbix监控端。"
echo "2.安装zabbix被监控机。"
echo "3 exit退出不执行脚本           "
}

zabbix_xiazai(){

yum=`yum repolist | awk -F: '/repolist/{print $2}' |sed 's/,//'`
[ $yum -gt 0 ] && echo "yum源可用" || echo "yum源不可用"
rpm -q wget
if [ $? -eq 0 ];then
echo "wget 已经安装"
else
echo "wget 未安装"
yum -y install wget
fi

zabbix_banben=2

read -p "
选择zabbix版本
1.zabbix-4.2版本
2.zabbix-4.0版本

默认安装4.0版本，请输入您要安装的版本序号(1/2)："  zabbix_banben

if [ $zabbix_banben == 1 ];then
	wget  -P /mnt/  https://www.mancxi.cn/sh/zabbix/zabbix-4.2.6.tar.gz  #下载zabbix软件tar包，来源于zabbix官网
	
elif [ $zabbix_banben == 2 ];then 
	wget  -P /mnt/  https://www.mancxi.cn/sh/zabbix/zabbix-4.0.12.tar.gz
	
elif [ $zabbix_banben -z ];then
	echo "请输入你要安装的版本序号"
fi

tar -xzvf /mnt/zabbix-*

rm -rf /mnt/zabbix-4*.tar.gz

}



zabbix_bendi(){
read -p '请输入zabbix安装文件的tar包所在路径:'  zabbix_lujin

tar -zxvf $zabbix_lujin  -C /mnt/

}

zabbix_anzhang(){

yum -y install net-snmp-devel curl-devel libevent-devel gcc pcre-devel zliv-devel openssl-dvel mariadb mariadb-devel mariadb-server  #安装所需依赖包

cd /mnt/zabbix-*

./configure --enable-server --enable-proxy --enable-agent --with-mysql=/usr/bin/mysql_config  --with-net-snmp-devel --with-libcurl   #编译安装zabbix

make install



}

mysql_config(){

databaname=zabbix

mysqluser=zabbix

mysqlpasswd=zabbix


systemctl restart mariadb

mysql -e "create database ${databaname} character set utf8;"

mysql -e "grant all on zabbix.* to zabbix@'localhost' identified by 'zabbix';"

cd /mnt/zabbix-*/database/mysql

mysql -u${mysqluser} -p${mysqlpasswd}  ${databaname} < schema.sql

mysql -u${mysqluser} -p${mysqlpasswd}  ${databaname} < images.sql

mysql -u${mysqluser} -p${mysqlpasswd}  ${databaname} < data.sql

sed -i "85s/.*/DBHost=localhost/" /usr/local/etc/zabbix_server.conf
sed -i "95s/.*/DBName=${databaname}/" /usr/local/etc/zabbix_server.conf
sed -i "111s/.*/DBUser=${mysqluser}/" /usr/local/etc/zabbix_server.conf
sed -i "119s/.*/DBPassword=${mysqlpasswd}/" /usr/local/etc/zabbix_server.conf
sed -i '38s/.*/LogFile=\/tmp\/zabbix_server.log/' /usr/local/etc/zabbix_server.conf

}

zabbix_web(){

wget -P /mnt/ http://www.mancxi.cn/sh/nginx.tar.gz

tar -zxvf /mnt/nginx.tar.gz

rm -rf /mnt/nginx.tar.gz

cd /mnt/nginx-*

./configure --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module

make && make install 

sed -i '45s/            index  index.html index.htm;/            index  index.php index.html index.htm;/'  /usr/local/nginx/conf/nginx.conf

sed -i '65s/#//' /usr/local/nginx/conf/nginx.conf
sed -i '66s/#//' /usr/local/nginx/conf/nginx.conf
sed -i '67s/#//' /usr/local/nginx/conf/nginx.conf
sed -i '68s/#//' /usr/local/nginx/conf/nginx.conf
sed -i '70s/#//' /usr/local/nginx/conf/nginx.conf
sed -i '71s/#//' /usr/local/nginx/conf/nginx.conf

sed -i '70s/fastcgi_params/fastcgi.conf/' /usr/local/nginx/conf/nginx.conf

sed -i '19a fastcgi_read_timeout 300;' /usr/local/nginx/conf/nginx.conf
sed -i '19a fastcgi_send_timeout 300;' /usr/local/nginx/conf/nginx.conf
sed -i '19a fastcgi_connect_timeout 300;' /usr/local/nginx/conf/nginx.conf
sed -i '19a fastcgi_buffer_size 32k;' /usr/local/nginx/conf/nginx.conf
sed -i '19a fastcgi_buffers 8 16k;' /usr/local/nginx/conf/nginx.conf

wget -P /mnt/ https://www.mancxi.cn/sh/zabbix/webtatic-release.rpm

yum -y install epel-release
yum -y install /mnt/webtatic-release.rpm

yum -y install php56w-fpm  php56w php56w-fpm php56w-mysql  php56w-gd  php56w-xml  php56w-ldap  php56w-bcmath php56w-mbstring

sed -i '878s/.*/date.timezone = Asia\/Shanghai/' /etc/php.ini
sed -i '384s/.*/max_execution_time = 300/' /etc/php.ini
sed -i '394s/.*/max_input_time = 300/' /etc/php.ini
sed -i '672s/.*/post_max_size = 32M/' /etc/php.ini
sed -i '705s/;//' /etc/php.ini

cp -a /mnt/zabbix-4.2.6/frontends/php/*  /usr/local/nginx/html/

chmod -R 777 /usr/local/nginx/html/*

}

zabbix_ok(){

rm -rf /mnt/zabbix-*

rm -rf /mnt/nginx-*

useradd zabbix
useradd nginx
/usr/local/nginx/sbin/nginx
systemctl start php-fpm
zabbix_server
systemctl restart mariadb

ss -antup | grep *:80
ss -antup | grep *:10051
ss -antup | grep *:3306
ss -antup | grep php-fpm

if [ $? -eq 0 ];then
	echo "
zabbix监控机服务安装完成!
mariadb数据库服务安装完成(请及时更改root密码)
web页面搭建完成,请及时访问web页面进行最后一步安装
访问地址：http://127.0.0.1/
安装过程：
1.点击“Next step”
2.再次点击“Next step”
3.请在“Database port”编辑框填入“ 3306 ”
4.请在“Password”编辑框填入“zabbix”
5.剩下的请一直点“Next step”

	"

fi
}

create_zabbix_agentd(){

read -P "请输入监控服务器的地址(不能为空)：" agentd_ip
agentd_ip=,${agentd_ip}
read -P "请输入监控服务器的端口(默认为10051)：" agentd_port

if [ ! -n "${agentd_port}" ];then
	agentd_port=:${agentd_port}
else
	agentd_port=
fi

agentd_ip_port=${agentd_ip}${agentd_port}

read -P "请输入监控端自己的主机名(不可跟已添加的重复)：" agentd_hostname


useradd -s /sbin/nologin  zabbix

yum -y install gcc pcre-devel

cd /mnt/zabbix-*

./configure --enable-agent 

make && make install 

/usr/local/etc/zabbix_agentd.conf

sed -i "94s/.*/server=127.0.0.1${agentd_ip_port}/" /usr/local/etc/zabbix_agentd.conf
sed -i "135s/.*/ServerActive=127.0.0.1${agentd_ip_port}/" /usr/local/etc/zabbix_agentd.conf
sed -i "146s/.*/Hostname=${agentd_hostname}/" /usr/local/etc/zabbix_agentd.conf
sed -i '69s/.*/EnableRemoteCommands=1/' /usr/local/etc/zabbix_agentd.conf
sed -i '281s/.*/UnsafeUserParameters=1/' /usr/local/etc/zabbix_agentd.conf

rm -rf /mnt/zabbix-*

zabbix_agentd

zabbix_agentd

ss -antup |grep *.10050
echo '
--------------------------------
|!!zabbix被监控机服务安装完成!!|
--------------------------------
'

}

while :
do
 menu
read -p "请输入你要创建的虚拟项(1-3):"  zz
case $zz in
1)
		while :
		do
		echo "选择您要通过什么方式安装："
		echo "1.网络安装(没tar包)"
		echo "2.本地安装(请提供下载到的tar包所在位置)"
		echo "！！直接回车默认为网络安装！！"
		
		read -p "请输入你要创建的虚拟项(1-2):"  hh
		case $hh in
		1)
			zabbix_xiazai;;
			zabbix_anzhang;;
			mysql_config;;
			zabbix_web;;
			zabbix_ok;;
		2)
			zabbix_bendi;;
			zabbix_anzhang;;
			mysql_config;;
			zabbix_web;;
			zabbix_ok;;
		*)
			echo "输入错误";;
		esac
		done
2)
		while :
		do
		echo "选择您要通过什么方式安装："
		echo "1.网络安装(没tar包)"
		echo "2.本地安装(请提供下载到的tar包所在位置)"
		echo "！！直接回车默认为网络安装！！"
		
		read -p "请输入你要创建的虚拟项(1-2):"  hh
		case $hh in
		1)
			zabbix_xiazai;;
			create_zabbix_agentd;;
		2)
			zabbix_bendi;;
			create_zabbix_agentd;;
		*)
			echo "输入错误";;
		esac
		done
3)
  exit;;
*)
  echo "输入错误";;
esac
done
