#!/bin/bash

# Start sshd if START_SSHD env variable is set
# This allows for remote access via PyCharm and ssh
if [[ "$START_SSHD" == "1" ]]; then
  /usr/sbin/sshd -p 22 &
fi

# Default to UTC if no TZ env variable is set
echo "Setting time zone to ${TZ=UTC}"
ln -fs "/usr/share/zoneinfo/${TZ}" /etc/localtime
dpkg-reconfigure tzdata

flask run --host=0.0.0.0
