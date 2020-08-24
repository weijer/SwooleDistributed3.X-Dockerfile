#!/bin/sh
yum groupinstall " Development Tools"  -y
yum install expat-devel pcre pcre-devel openssl-devel -y
mkdir /opt/httpd
chmod -R 755 /opt/httpd
cd /opt/httpd
wget http://mirrors.viethosting.com/apache//httpd/httpd-2.4.46.tar.gz -O httpd-2.4.46.tar.gz
wget https://github.com/apache/apr/archive/1.7.0.tar.gz -O apr-1.7.0.tar.gz
wget https://github.com/apache/apr-util/archive/1.6.1.tar.gz -O apr-util-1.6.1.tar.gz
tar -zxvf httpd-2.4.46.tar.gz
tar -zxvf apr-1.7.0.tar.gz
tar -zxvf apr-util-1.6.1.tar.gz
mv apr-1.7.0 /opt/httpd/httpd-2.4.46/srclib/apr
mv apr-util-1.6.1 /opt/httpd/httpd-2.4.46/srclib/apr-util
cd /opt/httpd/httpd-2.4.46
./buildconf 
./configure --enable-ssl --enable-so --with-included-apr --with-ssl=/usr/local/openssl --prefix=/usr/local/apache2
make
make install
echo 'alias httpd="/usr/local/apache2/bin/httpd"' &>> /etc/profile.d/httpd.sh
echo 'ServerName localhost' &>> /usr/local/apache2/conf/httpd.conf
# Apache gets grumpy about PID files pre-existing
