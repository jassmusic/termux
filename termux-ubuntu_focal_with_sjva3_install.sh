#!/bin/sh

# Termux-Ubuntu_focal with SJVA3 Install
# made by jassmusic @21.6.09

echo ""
echo "-- SJVA3 Install for Termux-Ubuntu_focal"
echo "   from SJVA.me @21.6.09--"
echo ""

termux-wake-lock

cd ~
rm -rf termux-ubuntu_focal_install.sh
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_focal_install.sh
bash termux-ubuntu_focal_install.sh
rm -rf ~/.bash_profile
cat >> ~/.bash_profile << EOF
termux-wake-lock
sshd
~/termux-ubuntu_focal/start-ubuntu.sh
EOF
rm termux-ubuntu_focal_install.sh

cd ~
rm -rf termux-ubuntu_focal_sjva3_install.sh
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_focal_sjva3_install.sh
mv termux-ubuntu_focal_sjva3_install.sh ~/termux-ubuntu_focal/ubuntu-fs/home
cat >> ~/termux-ubuntu_focal/ubuntu-fs/root/.bash_profile << EOF
bash /home/termux-ubuntu_focal_sjva3_install.sh
EOF
~/termux-ubuntu_focal/start-ubuntu.sh
fi
