#!/bin/bash

ping -c4 8.8.8.8 > /dev/null

if [ $? != 0 ]
then
  curl -X POST --header "Content-Type:application/json" "$BALENA_SUPERVISOR_ADDRESS/v1/reboot?apikey=$BALENA_SUPERVISOR_API_KEY"
else
  echo "$(date): network up"
fi
