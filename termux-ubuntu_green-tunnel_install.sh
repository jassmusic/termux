#!/bin/sh

# Termux-Ubuntu green-tunnel install
# made by jassmusic @21.2.17


echo "green-tunnel을 설치합니다."
echo "Step1) 필수 package 설치"
apt -y install build-essential curl lsb-release
curl -sL https://deb.nodesource.com/setup_14.x | bash -

echo "Step2) green-tunnel 설치"
apt -y install nodejs
npm i -g green-tunnel

echo "Step3) 실행스크립트 등록"
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_sysinit_green-tunnel
cp -f termux-ubuntu_sysinit_green-tunnel /etc/init.d/green-tunnel
rm -f termux-ubuntu_sysinit_green-tunnel
chmod +x /etc/init.d/green-tunnel
update-rc.d green-tunnel defaults
echo ""
echo "설치가 완료되었습니다."
echo "※ 아래 명령으로 실행가능합니다."
echo "service green-tunnel {port} {start|stop|restart|status}"
echo "service green-tunnel {start|stop|restart|status}"
echo "※ 만약 {port} 를 스킵할 경우"
echo "    '7000' 으로 기본설정됩니다."
echo " : service green-tunnel start"
echo "   (7000 port)"
echo ": service green-tunnel 8080 start"
echo ": service green-tunnel 8090 restart"
echo ": service green-tunnel stop"
echo ": service green-tunnel status"
echo " enjoy!"