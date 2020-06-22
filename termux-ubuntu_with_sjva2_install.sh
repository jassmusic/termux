#!/bin/sh

# Termux-Ubuntu Install
# made by jassmusic @20.06.22
# (modify from Neo-Oli/termux-ubuntu)

cd ~
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_install.sh
bash termux-ubuntu_install.sh
sleep 1
cat >> ~/.bash_profile << EOF
termux-wake-lock
sshd
~/termux-ubuntu/start-ubuntu.sh
EOF
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_sjva2_install.sh
mv termux-ubuntu_sjva2_install.sh ~/termux-ubuntu/ubuntu-fs/home
cat >>  ~/termux-ubuntu/ubuntu-fs/root/.bash_profile << EOF
bash /home/termux-ubuntu_sjva2_install.sh
EOF
~/termux-ubuntu/start-ubuntu.sh
