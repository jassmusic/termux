#!/bin/sh

# Termux-Ubuntu Apache2 & php set
# made by jassmusic @21.02.09
# auto editing /etc/apache2/ports.conf
# auto editing /etc/apache2/apache2.conf

#### set apache2 port what you want
APACHE_PORT="8000"

# install package
apt install -y apache2 php libapache2-mod-php
# support webtoon
apt install -y php7.3-mbstring php7.3-gd php7.3-curl php7.3-xml php7.3-soap php7.3-gmp php7.3-json php7.3-zip php7.3-sqlite3 php7.3-bcmath php7.3-xmlrpc php7.3-bz2 php7.3-mbstring php7.3-gd php7.3-curl php7.3-xml php7.3-soap php7.3-gmp php7.3-json php7.3-zip php7.3-sqlite3 php7.3-bcmath php7.3-xmlrpc php7.3-bz2

# change port
sed -i "s/Listen 80/Listen ${APACHE_PORT}/" /etc/apache2/ports.conf

# add ServerName
sed -i '/#ServerRoot "\/etc\/apache2"/i \
ServerName localhost' /etc/apache2/apache2.conf

# make symbolic link
ln -s /var/www/html /home/html

echo ""
echo " Finish! -- run 'service apache2 start'"
echo "         -- address 'http://your-address:${APACHE_PORT}'"
echo "         -- based folder '/home/html'"
echo ""
