#!/bin/sh

# Termux Apache2 & php set
# made by jassmusic @20.07.06
# auto editing /data/data/com.termux/files/usr/etc/apache2/httpd.conf

# set apache2 port
APACHE_PORT="8000"

# install package
apt install -y php-apache

# add ServerName
sed -i '/ServerRoot "\/data\/data\/com.termux\/files\/usr"/i \
ServerName localhost' /data/data/com.termux/files/usr/etc/apache2/httpd.conf

# change port
sed -i "s/Listen 8080/Listen ${APACHE_PORT}/" /data/data/com.termux/files/usr/etc/apache2/httpd.conf

# prefork uncomment
sed -i 's/#LoadModule mpm_prefork_module libexec\/apache2\/mod_mpm_prefork.so/LoadModule mpm_prefork_module libexec\/apache2\/mod_mpm_prefork.so/' /data/data/com.termux/files/usr/etc/apache2/httpd.conf

# worker comment
sed -i 's/LoadModule mpm_worker_module libexec\/apache2\/mod_mpm_worker.so/\#LoadModule mpm_worker_module libexec\/apache2\/mod_mpm_worker.so/' /data/data/com.termux/files/usr/etc/apache2/httpd.conf

# add Module
sed -i '/LoadModule authn_file_module libexec\/apache2\/mod_authn_file.so/i \
LoadModule php7_module /data/data/com.termux/files/usr/libexec/apache2/libphp7.so\
<FilesMatch \\.php$>\
SetHandler application/x-httpd-php\
<\/FilesMatch>' /data/data/com.termux/files/usr/etc/apache2/httpd.conf

# make symbolic link
ln -s /data/data/com.termux/files/usr/share/apache2/default-site/htdocs ~/html
echo ""
echo " Finish! -- run 'apachectl start'"
echo "         -- address 'http://your-address:${APACHE_PORT}'"
echo "         -- based folder '~/html'"
echo ""
