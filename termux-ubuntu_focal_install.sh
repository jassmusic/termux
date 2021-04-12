#!/bin/sh

# Termux-Ubuntu_focal
# made by jassmusic @21.2.20
# (modify from Neo-Oli/termux-ubuntu)

echo ""
echo "-- Termux-Ubuntu Install"
echo "   from SJVA.me --"
echo "   version 21.2.20"
echo ""

cd ~
dir=termux-ubuntu_focal
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
echo "- download ubuntu-focal image"
mkdir -p "$dir"
cd "$dir"
case `dpkg --print-architecture` in
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
wget "https://partner-images.canonical.com/core/focal/current/ubuntu-focal-core-cloudimg-${archurl}-root.tar.gz" -O $tarball
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
#sed -i 's,http://ports.ubuntu.com/ubuntu-ports/,http://old-releases.ubuntu.com/ubuntu/,g' etc/apt/sources.list
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
command+=" -b /storage"
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
echo "* Just run '${cur}/${bin}' for Termux-Ubuntu session."
fi
