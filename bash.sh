#!/bin/bash
yum -y install expect 

vm7(){

    for i in 96 97 98 99
    do
expect <<EOF
spawn clone-vm7
expect "Enter VM number:" {send "$i\r"}
expect "#"                {send "exit\r"}
expect "#"                {send "exit\r"}
EOF
    done 
} 



cp96(){

virsh start tedu_node96
expect <<oppo
set timeout 35
spawn virsh console tedu_node96
expect "localhost login:"           {send "root\r"}
expect "Password:"                  {send "123456\r"}
expect "#"                          {send "nmcli connection modify eth2 ipv4.method maunal ipv4.addresses 201.1.1.100/24 connection.autoconnect yes\r"}
expect "#"                          {send "nmcli connection up eth2\r"}
expect "#"                          {send "exit\r"}
oppo

cd /linux-soft/02/
tar -xf lnmp_soft.tar.gz
cd lnmp_soft/
scp nginx-1.12.2.tar.gz root@201.1.1.100:/root/

expect <<oppo
spawn ssh root@201.1.1.100
set timeout 3
expect "#"                  {send "tar -xf nginx-1.12.2.tar.gz\r"}
expect "#"                  {send "cd nginx-1.12.2\r"}
expect "#"                  {send "useradd -s /sbin/nologin nginx\r"}
expect "#"                  {send "./configure --user=nginx -- group=ngix  --with-http_ssl_module  --with-stream --with-http_stub_status_module\r"}
expect "#"                  {send "make && make install "}

}

