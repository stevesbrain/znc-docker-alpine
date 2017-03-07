#!/bin/sh

# "docker run -ti znc sh" should work, according to
# https://github.com/docker-library/official-images
if [ "${1:0:1}" != '-' ]; then
    exec "$@"
fi

if [-e /znc-data/configs/znc.conf ]; then
    echo "Doing nothing; conf exists"
  else
	  mkdir -p /znc-data/configs
	  mkdir -p /znc-data/moddata
	  mkdir -p /znc-data/users
	  /opt/znc/bin/znc -p -d /znc-data/ 
	  cp /docker/znc.conf.example /znc-data/configs/znc.conf
fi
    

# Options.
DATADIR="/znc-data"

# Make sure $DATADIR is owned by znc user. This affects ownership of the
# mounted directory on the host machine too.
#chown -R znc:znc "$DATADIR" || exit 1
#chmod 700 "$DATADIR" || exit 2

# This file is added by znc:full image
if [ -r /znc-build-modules.sh ]; then
    source /znc-build-modules.sh || exit 3
fi

cd /

# ZNC itself responds to SIGTERM, and reaps its children, but whatever was
# started via *shell module is not guaranteed to reap their children.
exec /sbin/tini -- /opt/znc/bin/znc --foreground --datadir "$DATADIR" "$@"
