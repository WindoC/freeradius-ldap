#!/bin/bash
set -e

TZ=${TZ:-Asia/Hong_Kong}
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# init script
/scripts/init.sh

# to turn on debugging, use "-x -f -l stdout"
RADIUSD_ARGS="${RADIUSD_ARGS:--f -l stdout}"

# Start freeradius
#/etc/init.d/freeradius start
echo "Starting freeradius ..."
freeradius $RADIUSD_ARGS
