#!/bin/bash

yum install -y wget && wget -O install.sh http://download.bt.cn/install/install_6.0.sh&&sh install.sh

rm -f /www/server/panel/data/admin_path.pl

cd /www/server/panel && python tools.py panel 123456

btuser=`cd /www/server/panel && python tools.py panel 123456`
