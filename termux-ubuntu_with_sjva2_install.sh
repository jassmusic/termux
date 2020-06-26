#!/bin/sh

# Termux-Ubuntu with SJVA2 Install
# made by jassmusic @20.06.26

echo ""
echo "-- SJVA2 Install for Termux-Ubuntu"
echo "   from nVidia Shield Cafe --"
echo "   version 0.2.6.26"
echo ""

termux-wake-lock

cd ~
rm -rf termux-ubuntu_install.sh
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_install.sh
bash termux-ubuntu_install.sh
rm -rf ~/.bash_profile
cat >> ~/.bash_profile << EOF
termux-wake-lock
sshd
~/termux-ubuntu/start-ubuntu.sh
EOF
rm termux-ubuntu_install.sh

cd ~
rm -rf termux-ubuntu_sjva2_install.sh
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_sjva2_install.sh
mv termux-ubuntu_sjva2_install.sh ~/termux-ubuntu/ubuntu-fs/home
cat >> ~/termux-ubuntu/ubuntu-fs/root/.bash_profile << EOF
bash /home/termux-ubuntu_sjva2_install.sh
EOF
~/termux-ubuntu/start-ubuntu.sh
fi
