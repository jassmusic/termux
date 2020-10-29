#!/data/data/com.termux/files/usr/bin/bash

pkg upgrade
pkg install termux-services
# basic application
apt -y install nmap git vim sqlite
# python application
apt -y install python libxml2 libxslt
# python3
python3 -m pip install --upgrade pip
pip3 install wheel
pip3 install flask-login flask-socketio flask-sqlalchemy pytz apscheduler selenium celery redis telepot sqlitedict
pip3 install lxml sqlalchemy gevent gevent-websocket pycryptodome markupsafe yarl aiohttp markdown

# ffmpeg
apt -y install ffmpeg
pip3 install pillow wcwidth google-api-python-client guessit plexapi

# install sjva2_src_obfuscate
git clone --depth 1 https://github.com/soju6jan/sjva2_src_obfuscate ~/app
mkdir -p ~/app/bin/LinuxArm
cd ~/app/bin/LinuxArm
curl -LO https://raw.githubusercontent.com/soju6jan/SJVA2/master/bin/LinuxArm/filebrowser
curl -LO https://raw.githubusercontent.com/soju6jan/SJVA2/master/bin/LinuxArm/rclone
chmod +x *
cd ~/app
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/my_start_termux-native.sh
mv my_start_termux-native.sh my_start_termux.sh
chmod +x my_start_termux.sh

# soju6jan git fork and modification for termux-native
#git clone https://github.com/jassmusic/nginx ~/app/data/custom/nginx
#~/app/data/custom/nginx/files/install.sh
