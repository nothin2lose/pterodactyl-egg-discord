#!/bin/bash

MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`

export COREPACK_ENABLE_DOWNLOAD_PROMPT=0

export COREPACK_HOME="/tmp/corepack"
corepack enable

echo "$ cd /home/container"
cd /home/container

echo "-- Server started"

${MODIFIED_STARTUP}
