#!/bin/sh

# Termux-Ubuntu Streamlink addset
# made by jassmusic @20.06.22

#apt install streamlink
#vim /var/lib/dpkg/info/libfprint0\:arm64.postinst # need to modify for 'apt install streamlink'

mv /usr/lib/python2.7/dist-packages/configparser-3.5.0b2-nspkg.pth /home
#cat /usr/lib/python2.7/dist-packages/backports/__init__.py
echo `# A Python "namespace package" http://www.python.org/dev/peps/pep-0382/` >> /usr/lib/python2.7/dist-packages/backports/__init__.py
echo `# This always goes inside of a namespace package's __init__.py` >> /usr/lib/python2.7/dist-packages/backports/__init__.py
echo `from pkgutil import extend_path` >> /usr/lib/python2.7/dist-packages/backports/__init__.py
echo `__path__ = extend_path(__path__, __name__)` >> /usr/lib/python2.7/dist-packages/backports/__init__.py
