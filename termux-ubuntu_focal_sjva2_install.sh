#!/bin/sh

# SJVA2 install for Termux-Ubuntu_focal
# made by jassmusic @21.2.20

echo ""
echo "-- SJVA 0.2 Install for Termux-Ubuntu"
echo "   from SJVA.me--"
echo "   version 21.2.20"
echo ""
sleep 1

echo "(Step1) dns setting.."
rm -f /etc/resolv.conf
cat >> /etc/resolv.conf << 'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
echo " done"
echo ""

echo "(Step2) Essential package setting.."
apt -y update && apt -y upgrade
apt -y install apt-utils vim dialog curl git busybox sqlite
apt-get install tzdata locales
dpkg-reconfigure tzdata
dpkg-reconfigure locales
echo " done"
echo ""

echo "(Step3) Build Package setting.."
apt -y install python3 python3-pip python3-dev python3-lxml
apt -y git libffi-dev libxml2-dev libxslt-dev zlib1g-dev libjpeg62-dev
echo " done"
echo ""

echo "(Step4) ffmpeg setting.."
apt -y install ffmpeg
echo " done"
echo ""

echo "(Step5) SJVA2 Downloading.."
cd /home
git clone --depth 1 https://github.com/soju6jan/sjva2_src_obfuscate /home/SJVA2
echo " done"
echo ""

echo "(Optional) Rclone setting.."
#curl https://rclone.org/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/wiserain/rclone/mod/install.sh | bash
mkdir -p /home/SJVA2/bin/LinuxArm
cp /bin/rclone /home/SJVA2/bin/LinuxArm
echo " done"
echo ""

echo "(Optional) filebrowser setting.."
#curl -fsSL https://filebrowser.xyz/get.sh | bash
#curl -fsSL https://filebrowser.org/get.sh | bash
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
mkdir -p /home/SJVA2/bin/LinuxArm
cp /usr/local/bin/filebrowser /home/SJVA2/bin/LinuxArm
echo " done"
echo ""

echo "(Step6) SJVA2 pip setting.."
cd SJVA2
python3 -m pip install --upgrade pip
pip3 install --upgrade setuptools
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-native_requirements.txt
pip3 install -r termux-native_requirements.txt
echo " done"
echo ""

echo "(Step7) Running file modify.."
rm -f my_start.sh
cat >> my_start.sh << 'EOM'
#!/bin/bash

if [ ! -f "export.sh" ] ; then
cat <<EOF >export.sh
#!/bin/sh
export REDIS_PORT="46379"
export USE_CELERY="false"
export CELERY_WORKER_COUNT="2"
export RUN_FILEBROWSER="true"
export FILEBROWSER_PORT="9998"
export OS_PREFIX="LinuxArm"
EOF
fi

if [ -f "export.sh" ] ; then
    echo "Run export.sh start"
    chmod 777 export.sh
    source export.sh
    echo "Run export.sh end"
fi

if [ -f "pre_start.sh" ] ; then
    echo "Run pre_start.sh start"
    chmod 777 pre_start.sh
    source pre_start.sh
    echo "Run pre_start.sh end"
fi

if [ "${USE_CELERY}" == "true" ] ; then
    nohup redis-server --port ${REDIS_PORT} &
    echo "Start redis-server port:${REDIS_PORT}"
fi

if [ "${RUN_FILEBROWSER}" == "true" ]; then
    chmod +x ./bin/${OS_PREFIX}/filebrowser
    nohup ./bin/${OS_PREFIX}/filebrowser -a 0.0.0.0 -p ${FILEBROWSER_PORT} -r / -d ./data/db/filebrowser.db -b /filebrowser &
    echo "Start Filebrowser. port:${FILEBROWSER_PORT}"
fi

COUNT=0
while [ 1 ];
do
    find . -name "index.lock" -exec rm -f {} \;
    git reset --hard HEAD
    git pull
    chmod 777 .
    chmod -R 777 ./bin

    if [ ! -f "./data/db/sjva.db" ] ; then
        python3 -OO sjva.py 0 ${COUNT} init_db
    fi

    if [ "${USE_CELERY}" == "true" ] ; then
        sh worker_start.sh &
        echo "Run celery-worker.sh"
        python3 -OO sjva.py 0 ${COUNT}
    else
        python3 -OO sjva.py 0 ${COUNT} no_celery
    fi
    
    RESULT=$?
    echo "PYTHON EXIT CODE : ${RESULT}.............."
    if [ "$RESULT" = "0" ]; then
        echo 'FINISH....'
        break
    else
        echo 'REPEAT....'
    fi 
    COUNT=`expr $COUNT + 1`
done 

if [ "${RUN_FILEBROWSER}" == "true" ]; then
    #ps -eo pid,args | grep filebrowser | grep -v grep | awk '{print $1}' | xargs -r kill -9
    pgrep -a filebrowser | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
fi
if [ -f "pre_start.sh" ] ; then
    echo "nginx, php-fpm stop"
    service php7.4-fpm stop
    source nginx stop
    echo " done"
fi
EOM
chmod 777 my_start.sh
echo " done"

echo "(Step8) Register SJVA2 to system service.."
rm -f /etc/init.d/sjva2
cat >> /etc/init.d/sjva2 << 'EOM'
#!/bin/sh
### BEGIN INIT INFO
# Provides: skeleton
# Required-Start: $remote_fs $syslog
# Required-Stop: $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Example initscript
# Description: This file should be used to construct scripts to be
# placed in /etc/init.d.
# Modified by jassmusic @20.06.22
### END INIT INFO
sjva2_running=`pgrep -a my_start.sh | awk '{ print $1 }'`
python_running=`pgrep -a python3 | grep sjva.py | awk '{ print $1 }'`
case "$1" in
start)
if [ -z "$sjva2_running" ] || [ -z "$python_running" ]; then
echo -n " Starting sjva2: "
cd /home/SJVA2
su -c "nohup ./my_start.sh &" >/dev/null 2>&1
sleep 1
echo "done"
else
echo " sjva2 already running"
exit 0
fi
;;
stop)
if [ -z "$sjva2_running" ] || [ -z "$python_running" ] ; then
echo -n " Checking sjva2: "
pgrep -a my_start.sh | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
pgrep -a python3 | grep sjva.py | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
pgrep -a filebrowser | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
sleep 1
echo "done"
echo " sjva2 is not running (no process found)..."
exit 0
fi
echo -n " Killing sjva2: "
pgrep -a my_start.sh | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
pgrep -a python3 | grep sjva.py | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
pgrep -a filebrowser | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
sleep 1
echo "done"
;;
restart)
sh $0 stop
sh $0 start
;;
status)
if [ -z "$sjva2_running" ] && [ -z "$python_running" ]; then
echo " It seems that sjva isn't running (no process found)."
else
echo " sjva2 process running"
fi
;;
*)
echo " Usage: $0 {start|stop|restart|status}"
exit 1
;;
esac
exit 0
EOM
chmod +x /etc/init.d/sjva2
update-rc.d sjva2 defaults
cd /home/SJVA2
echo " done"
echo ""

echo "(Step9) Register SJVA2 to Autorun.."
rm -f ~/.bash_profile
cat >> ~/.bash_profile << 'EOF'
echo ""
echo "Welcome to Termux Ubuntu!"
echo "e.g) SJVA manual instruction"
echo "     service sjva2 start"
echo "     service sjva2 stop"
echo "     service sjva2 restart"
echo "     service sjva2 status"
echo ""
echo "Run SJVA with background..."
#sleep 1
service sjva2 start
echo ""
EOF
echo " done"
echo ""
echo " : From now you can access as below,"
echo " : service sjva2 start"
echo " : service sjva2 stop"
echo " : service sjva2 restart"
echo " : service sjva2 status"
echo ""
echo "SJVA2 Installed finish."
echo "enjoy!"
