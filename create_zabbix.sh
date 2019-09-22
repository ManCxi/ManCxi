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

mysqlpasswd=zabbix  #zabbix库 zabbix用户的密码


systemctl restart mariadb

mysql -e "create database ${databaname} character set utf8;"

mysql -e "grant all on ${databaname}.* to ${mysqluser}@'localhost' identified by "${mysqlpasswd}";"

cd /mnt/zabbix-*/database/mysql

mysql -u${mysqluser} -p${mysqlpasswd}  ${databaname} < schema.sql

mysql -u${mysqluser} -p${mysqlpasswd}  ${databaname} < images.sql

mysql -u${mysqluser} -p${mysqlpasswd}  ${databaname} < data.sql

sed -i "85s/.*/DBHost=localhost/" /usr/local/etc/zabbix_server.conf
sed -i "95s/.*/DBName=${databaname}/" /usr/local/etc/zabbix_server.conf
sed -i "111s/.*/DBUser=${mysqluser}/" /usr/local/etc/zabbix_server.conf
sed -i "119s/.*/DBPassword=${mysqlpasswd}/" /usr/local/etc/zabbix_server.conf
sed -i "38s/.*/LogFile=/tmp/zabbix_server.log/" /usr/local/etc/zabbix_server.conf

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


/usr/local/nginx/conf/nginx
systemctl start php-fpm
zabbix_server

}

zabbix_ok(){

/usr/local/nginx/conf/nginx
systemctl start php-fpm
zabbix_server
systemctl restart mariadb
if [ $? -eq 0 ];then
	echo "zabbix监控机安装完成。"
	echo "mariadb数据库安装完成(请及时更改root密码)"
	echo "web页面搭建完成："
	echo "访问地址：http://127.0.0.1/"
	
fi
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
			install_vm2;;
		*)
			echo "输入错误";;
		esac
		done
2)
  install_vm2;;
3)
  exit;;
*)
  echo "输入错误";;
esac
done
