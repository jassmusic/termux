#!/bin/sh

# Termux-Ubuntu with SJVA2 Install
# made by jassmusic @20.06.24

echo ""
echo "-- SJVA2 Install for Termux-Ubuntu"
echo "   from nVidia Shield Cafe --"
echo "   version 0.2.6.24"
echo ""

cd ~
dir=termux-ubuntu
folder=ubuntu-fs
cur=`pwd`
echo "- checking the folder"
if [ -d "${cur}/${dir}" ]; then
echo "  already used. need to change or delete"
echo "   e.g) rm -rf ${cur}/${dir}"
else
echo "  OK"
echo "- install essential package"
pkg install -y git wget vim proot termux-exec
echo "  done"
echo "- download ubuntu-eoan image"
mkdir -p "$dir"
cd "$dir"
case arm in
aarch64)
archurl="arm64" ;;
arm)
archurl="armhf" ;;
amd64)
archurl="amd64" ;;
i*86)
archurl="i386" ;;
x86_64)
archurl="amd64" ;;
*)
echo "  unknown architecture"; exit 1 ;;
esac
tarball=ubuntu.${archurl}.tar.gz
wget "https://partner-images.canonical.com/core/eoan/current/ubuntu-eoan-core-cloudimg-${archurl}-root.tar.gz" -O $tarball
echo "  done"
cur=`pwd`
mkdir -p "$folder"
cd "$folder"
echo "decompressing ubuntu image"
proot --link2symlink tar -xf ${cur}/${tarball} --exclude='dev'||:
echo "  done"
echo "- change dns setting"
rm -rf etc/resolv.conf
cat >> etc/resolv.conf << 'EOM'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOM
rm ${cur}/${tarball}
echo "  done"
echo "- make launch script"
cd "$cur"
mkdir -p binds
bin=start-ubuntu.sh
cat > "$bin" <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A binds)" ]; then
	for f in binds/* ;do
		. \$f 
	done
fi
command+=" -b /dev"
command+=" -b /proc"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
command+=" -b /data/data/com.termux/files/home:/termux"
## uncomment the following line to mount /sdcard directly to /
command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
	exec \$command
else
	\$command -c "\$com"
fi
EOM
echo "- fixing shebang of "
termux-fix-shebang $bin
chmod +x "$bin"
echo "  done"
echo "Finish!"
#echo "* Just run '${cur}/${bin}' for Termux-Ubuntu session."
#fi
cat >> ~/.bash_profile << EOF
termux-wake-lock
sshd
~/termux-ubuntu/start-ubuntu.sh
EOF
cd ~
rm -rf termux-ubuntu_sjva2_install.sh
curl -LO https://raw.githubusercontent.com/jassmusic/termux/master/termux-ubuntu_sjva2_install.sh
mv termux-ubuntu_sjva2_install.sh ~/termux-ubuntu/ubuntu-fs/home
cat >> ~/termux-ubuntu/ubuntu-fs/root/.bash_profile << EOF
bash termux-ubuntu_sjva2_install.sh
EOF
~/termux-ubuntu/start-ubuntu.sh
fi
