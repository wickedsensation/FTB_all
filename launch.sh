#!/bin/bash

set -x

/bwlimit.sh

cd /data

if [ -z "${VERSION}" ] || [ -z "${BUILD}" ]; then
  echo "VERSION or BUILD variable not set. Skipping server installation."
fi

VERSION="${VERSION:-}"
BUILD="${BUILD:-}"

if ! [[ -f serverinstall_${VERSION}_${BUILD} ]]; then
	rm -fr config defaultconfigs kubejs libraries log4jfix mods resourcepacks minecraft-server-1.*.*.jar version.json start.sh run.* user_jvm_args.txt serverinstall_${VERSION}_*
	wget https://api.modpacks.ch/public/modpack/${VERSION}/${BUILD}/server/linux -O serverinstall_${VERSION}_${BUILD}
	mv serverinstall_${VERSION}_${BUILD} /data/
	chmod +x /data/serverinstall_${VERSION}_${BUILD}
	/data/serverinstall_${VERSION}_${BUILD} -auto
fi

if ! [[ -f server-icon.png ]]; then
	mv /stoneblock-3.png /data/server-icon.png
fi

if ! [[ "$EULA" = "false" ]] || grep -i true eula.txt; then
	echo "eula=true" > eula.txt
else
	echo "You must accept the EULA by in the container settings."
	exit 9
fi

if [[ -n "$MOTD" ]]; then
    sed -i "/motd\s*=/ c motd=$MOTD" server.properties
fi
if [[ -n "$LEVEL" ]]; then
    sed -i "/level-name\s*=/ c level-name=$LEVEL" server.properties
fi
if [[ -n "$LEVELTYPE" ]]; then
    sed -i "/level-type\s*=/ c level-type=$LEVELTYPE" server.properties
fi

echo "$JVM_OPTS" > user_jvm_args.txt

if [[ -n "$OPS" ]]; then
    echo $OPS | awk -v RS=, '{print}' >> ops.txt
fi

# set max ram in MB
ram=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)

ram_mb=$(expr $ram / 1024 / 1024)

heap_size=$(expr $ram_mb \* 99 / 100)

echo "-Xmx${heap_size}m" >> /data/user_jvm_args.txt

./start.sh
