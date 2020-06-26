#!/bin/sh

# Termux-Alpine SJVA2 addset
# made by jassmusic @20.06.26

echo "kill filebrowser prpcess"
pgrep -a filebrowser | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
#ps ax | grep /data/db | grep /filebrowser | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
echo " done"
echo ""

echo "(Step1) SJVA2 Running file modify.." 
apk add bash
rm -f /home/SJVA2/my_start.sh
cat >> /home/SJVA2/my_start.sh << 'EOM'
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
nohup ./bin/${OS_PREFIX}/filebrowser -a 0.0.0.0 -p ${FILEBROWSER_PORT} -r / -d ./data/db/filebrowser.db &
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
python -OO sjva.py 0 ${COUNT} init_db
fi
if [ "${USE_CELERY}" == "true" ] ; then
sh worker_start.sh &
echo "Run celery-worker.sh"
python -OO sjva.py 0 ${COUNT}
else
python -OO sjva.py 0 ${COUNT} no_celery
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
EOM
chmod 777 /home/SJVA2/my_start.sh
echo " done"

echo "(Step2) Set the System Running"
apk add openrc
cat >> /etc/init.d/sjva2 << 'EOF'
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
# Modified by jassmusic
### END INIT INFO
sjva2_running=`pgrep -a my_start | awk '{ print $1 }'`
python_running=`ps ax | grep python | grep sjva.py | awk '{ print $1 }'`
case "$1" in
start)
if [ -z "$sjva2_running" ] || [ -z "$python_running" ]; then
echo -n "Starting sjva2: "
cd /home/SJVA2
su -c "nohup ./my_start.sh &" >/dev/null 2>&1
sleep 1
echo "done"
else
echo "sjva2 already running"
exit 0
fi
;;
stop)
if [ -z "$sjva2_running" ] || [ -z "$python_running" ]; then
echo -n "Checking sjva2: "
pgrep -a my_start | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
ps ax | grep python | grep sjva.py | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
pgrep -a filebrowser | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
sleep 1
echo "done"
echo "sjva2 is not running (no process found)..."
exit 0
fi
echo -n "Killing sjva2: "
pgrep -a my_start | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
ps ax | grep python | grep sjva.py | awk '{ print $1 }' | xargs kill -9 >/dev/null 2>&1
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
echo "It seems that sjva isn't running (no process found)."
else
echo "sjva2 process running."
fi
;;
*)
echo "Usage: $0 {start|stop|restart|status}"
exit 1
;;
esac
exit 0
EOF
chmod +x /etc/init.d/sjva2
rc-update add sjva2
echo " done"

echo "(Step3) Set the Autorun SJVA"
rm /root/.profile
cat >> /root/.profile << 'EOF'
echo ""
echo "Welcome to Termux Alpine!"
echo "e.g) SJVA manual instruction"
echo " rc-service sjva2 start"
echo " rc-service sjva2 stop"
echo " rc-service sjva2 status"
echo " rc-service sjva2 restart"
echo ""
echo "Run SJVA with background..."
rc-service sjva2 start
echo ""
EOF
echo " done"
echo "Installed complete."
echo "Need to terminate termux & restart"
echo ""
