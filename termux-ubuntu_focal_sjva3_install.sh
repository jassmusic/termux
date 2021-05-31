#!/bin/sh

# SJVA3 install for Termux-Ubuntu_focal
# made by jassmusic @21.5.31

echo ""
echo "-- SJVA3 Install for Termux-Ubuntu_focal"
echo "   from SJVA.me--"
echo "   version 21.5.31"
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

echo "(Step5) Rclone setting.."
#curl https://rclone.org/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/wiserain/rclone/mod/install.sh | bash
echo " done"
echo ""

echo "(Step6) filebrowser setting.."
#curl -fsSL https://filebrowser.xyz/get.sh | bash
curl -fsSL https://filebrowser.org/get.sh | bash
echo " done"
echo ""

echo "(Step7) php7.4 install.."
apt -y install php7.4 php7.4-fpm php7.4-soap php7.4-gmp php7.4-json php7.4-zip php7.4-sqlite3 php7.4-xml php7.4-common php7.4-mysql php7.4-xmlrpc php7.4-bz2 php7.4-gd php7.4-bcmath php7.4-gd php7.4-odbc php7.4-curl php7.4-mbstring php7.4-apcu
service php7.4-fpm start
service php7.4-fpm stop
echo " done"
echo ""

echo "(Step8) nginx install.."
apt -y nginx sqlite
service nginx stop
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_focal_nginx.conf
rm /etc/nginx/nginx.conf
mv termux-ubuntu_focal_nginx.conf /etc/nginx/nginx.conf
echo " done"
echo ""

echo "(Step9) SJVA3 Downloading.."
cd /home
git clone --depth 1 git://github.com/soju6jan/SJVA3.git /home/SJVA3
echo " done"
echo ""

echo "(Step10) SJVA3 pip setting.."
cd SJVA3
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_focal_requirements.txt
python3 -m pip install --upgrade pip
pip3 install --upgrade setuptools
pip3 install -r termux-ubuntu_focal_requirements.txt
echo " done"
echo ""

echo "(Step11) pre_start.sh making.."
cat >> pre_start.sh << 'EOM'
#!/bin/sh

SJVA_HOME=/home/SJVA3
DIR_DATA=$SJVA_HOME/data

nohup filebrowser -a 0.0.0.0 -p 9998 -r / -d $DIR_DATA/db/filebrowser.db -b /filebrowser &
echo "Start Filebrowser port 9998"

service nginx start
service php7.4-fpm start
EOM
chmod 777 pre_start.sh
echo " done"

echo "(Step12) Running file making.."
rm -f my_start.sh
cat >> my_start.sh << 'EOM'
#!/bin/bash

#=======================================
SJVA_HOME=/home/SJVA3
DIR_DATA=$SJVA_HOME/data
PROGRAM_PATH=$DIR_DATA/programs
DIR_BIN=/usr/bin
GIT="git://github.com/soju6jan/SJVA3.git"
#=======================================
SCRIPT_TYPE="ubuntu"
SCRIPT_VERSION="1.0.5"
PYTHON="python3"
PIP="pip3"
PACKAGE_CMD="apt-get -y --no-install-recommends"
PS_COMMAND="pgrep -a ''"
PATH_PREFIX=""
#=======================================
PLUGIN_UPDATE_FROM_PYTHON="false"
#=======================================

if [ ! -f "export.sh" ] ; then
cat <<EOF >export.sh
#!/bin/sh
export REDIS_PORT="46379"
export CELERY_WORKER_COUNT="2"
export C_FORCE_ROOT="true"
export USE_GEVENT="true"
export USE_CELERY="false"
export SJVA_PORT="19999"
export PLUGIN_UPDATE_FROM_PYTHON="false"
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

if [ -e /etc/init.d/redis-server ]; then
    if [ "$USE_CELERY" == "true" ]; then
        echo "Run redis-server start"
        service redis-server start
    else
        echo "redis-server stop"
        service redis-server stop
    fi
fi

COUNT=0
while true;
do
    source export.sh
    export PLUGIN_UPDATE_FROM_PYTHON="false"
    if [ "$UPDATE_STOP" == "true" ]; then
        echo "pass git reset !!"
    else
        find $SJVA_HOME/.git -name "index.lock" -exec rm -f {} \;
        git reset --hard HEAD
        git pull
        if [ "$PLUGIN_UPDATE_FROM_PYTHON" == "false" ]; then
            echo "PLUGIN_UPDATE_FROM_SCRIPT"
                echo "plugin update"
                SECRET_KEY='foobar'
                export SECRET_KEY
                python3 -c "import os; print( os.environ.get('SECRET_KEY', 'Nonesuch'))"
                REPOS="$(ls $DIR_DATA/custom)"
                for repo in $REPOS
                do
                    if [ -d "$DIR_DATA/custom/${repo}" ]; then
                        if [ -d "$DIR_DATA/custom/$repo/.git" ] && [ ! -e "$DIR_DATA/custom/$repo/.update_stop" ]; then
                            echo $LINE
                            echo "플러그인 : $repo"
                            find $DIR_DATA/custom/$repo/.git -name "index.lock" -exec rm -f {} \;
                            git -C $DIR_DATA/custom/$repo reset --hard HEAD
                            git -C $DIR_DATA/custom/$repo pull
                            echo $LINE
                            echo -e '\n'
                        fi
                    fi
                done
        else
            ehco "PLUGIN_UPDATE_FROM_PYTHON"
        fi
    fi

    if [ -e /etc/init.d/sjva3_celery ]; then
        if [ "$USE_CELERY" == "true" ]; then
# /etc/default/sjva3_celery worker 카운트 적용
cat <<EOF >/etc/default/sjva3_celery
#!/bin/sh -e
source $SJVA_HOME/export.sh
export PLUGIN_UPDATE_FROM_PYTHON="false"
CELERY_APP="sjva3.celery"
CELERYD_CHDIR="${SJVA_HOME}"
CELERY_BIN="celery"
CELERYD_USER="root"
CELERYD_GROUP="root"
CELERY_BIN="/usr/local/bin/celery"
CELERYD_OPTS='-c $CELERY_WORKER_COUNT'
EOF
            chmod +x /etc/default/sjva3_celery
            #service sjva3_celery restart
            $PS_COMMAND | grep sjva3.celery | grep -v grep | awk '{print $1}' | xargs -r kill -9
            service sjva3_celery start
        else
            service sjva3_celery stop
        fi
    fi
    if [ -z $SJVA_PORT ]; then
        $PYTHON -u sjva3.py --repeat ${COUNT} --use_gevent ${USE_GEVENT} --use_celery ${USE_CELERY}
    else
        $PYTHON -u sjva3.py --repeat ${COUNT} --use_gevent ${USE_GEVENT} --use_celery ${USE_CELERY} --port $SJVA_PORT
    fi
    RESULT=$?
    echo "PYTHON EXIT CODE : ${RESULT}.............."
    if [ "$RESULT" = "1" ]; then
        echo 'REPEAT....'
    else
        echo 'FINISH....'
        break
    fi
    COUNT=`expr $COUNT + 1`
done

if [ -e /etc/init.d/redis-server ]; then
    service redis-server stop
fi
if [ -e /etc/init.d/sjva3_celery ]; then
    service sjva3_celery stop
fi
if [ -f "pre_start.sh" ]; then
    echo "filebrowser stop"	
    $PS_COMMAND | grep filebrowser | grep -v grep | awk '{print $1}' | xargs -r kill -9
    echo " done"
    echo "nginx, php-fpm stop"
    service php7.4-fpm stop
    service nginx stop
    echo " done"
fi
EOM
chmod 777 my_start.sh
echo " done"

echo "(Step13) Register SJVA3 to system service.."
rm -f /etc/init.d/sjva3
cat >> /etc/init.d/sjva3 << 'EOM'
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
# Modified by jassmusic @21.5.31
### END INIT INFO
sjva3_running=`pgrep -a my_start.sh | awk '{ print $1 }'`
python_running=`pgrep -a python3 | grep sjva3.py | awk '{ print $1 }'`
case "$1" in
start)
if [ -z "$sjva3_running" ] || [ -z "$python_running" ]; then
echo -n " Starting SJVA3: "
cd /home/SJVA3
su -c "nohup ./my_start.sh &" >/dev/null 2>&1
sleep 1
echo "done"
else
echo " SJVA3 already running"
exit 0
fi
;;
stop)
if [ -z "$sjva3_running" ] || [ -z "$python_running" ] ; then
echo -n " Checking SJVA3: "
pgrep -a my_start.sh | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
pgrep -a python3 | grep sjva3.py | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
pgrep -a filebrowser | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
sleep 1
echo "done"
echo " sjva2 is not running (no process found)..."
exit 0
fi
echo -n " Killing SJVA3: "
pgrep -a my_start.sh | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
pgrep -a python3 | grep sjva3.py | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
pgrep -a filebrowser | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
sleep 1
echo "done"
;;
restart)
sh $0 stop
sh $0 start
;;
status)
if [ -z "$sjva3_running" ] && [ -z "$python_running" ]; then
echo " It seems that sjva isn't running (no process found)."
else
echo " SJVA3 process running"
fi
;;
*)
echo " Usage: $0 {start|stop|restart|status}"
exit 1
;;
esac
exit 0
EOM
chmod +x /etc/init.d/sjva3
update-rc.d sjva3 defaults
cd /home/SJVA3
echo " done"
echo ""

echo "(Step14) Register SJVA3 to Autorun.."
rm -f ~/.bash_profile
cat >> ~/.bash_profile << 'EOF'
echo ""
echo "Welcome to Termux Ubuntu!"
echo "e.g) SJVA manual instruction"
echo "     service sjva3 start"
echo "     service sjva3 stop"
echo "     service sjva3 restart"
echo "     service sjva3 status"
echo ""
echo "Run SJVA3 with background..."
#sleep 1
service sjva3 start
echo ""
EOF
echo " done"
echo ""
echo " : From now you can access as below,"
echo " : service sjva3 start"
echo " : service sjva3 stop"
echo " : service sjva3 restart"
echo " : service sjva3 status"
echo ""
echo "SJVA3 Installed finish."
echo "enjoy!"
