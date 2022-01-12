#!/bin/bash

# Default to UTC if no TZ env variable is set
echo "Setting time zone to ${TZ=UTC}"
ln -fs "/usr/share/zoneinfo/${TZ}" /etc/localtime
dpkg-reconfigure tzdata

envsubst < /app/wifi-check.sh | sponge /app/wifi-check.sh

cron -f
