#!/bin/sh

# Termux-Ubuntu with SJVA2 Install
# made by jassmusic @20.06.22

echo ""
echo "-- SJVA2 Install for Termux-Ubuntu"
echo "   from nVidia Shield Cafe --"
echo "   version 0.2.6.22"
echo ""

cd ~
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_install.sh
bash termux-ubuntu_install.sh
sleep 1
cat >> ~/.bash_profile << EOF
termux-wake-lock
sshd
~/termux-ubuntu/start-ubuntu.sh
EOF
cd ~
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_sjva2_install.sh
mv termux-ubuntu_sjva2_install.sh ~/termux-ubuntu/ubuntu-fs/home
cat >> ~/termux-ubuntu/ubuntu-fs/root/.bash_profile << EOF
bash termux-ubuntu_sjva2_install.sh
EOF
bash ~/termux-ubuntu/start-ubuntu.sh
