#!/bin/sh

#### WHAT THIS DOES ####
# 
# If you have a dynamic IP address and require the setting 'usenatip' in
# the iroffer config file, then this script can auto-generate a one-line
# config file containing your current IP address. Run iroffer with
# multiple config files (your normal config plus this auto-generated
# config).
#
# If your IP address changes, the config file will be updated by this
# script and iroffer rehashed to see the change.
#
# Call this script when your IP changes or put in in your crontab.
# Run "crontab -e" and place the following line in the editor:
# * * * * * /full/path/to/iroffer/dynip.sh

CONFIGFILE="dynip.config"
PIDFILE="mybot.pid"

set -e
set -u

dig +short myip.opendns.com @resolver1.opendns.com \
 |sed -e 's=^=usenatip =' \
 > ${CONFIGFILE}.tmp

test -f ${CONFIGFILE} || touch ${CONFIGFILE}

if diff ${CONFIGFILE} ${CONFIGFILE}.tmp; then
  echo ip unchanged
  rm -f ${CONFIGFILE}.tmp
else
  echo ip changed
  mv -f ${CONFIGFILE}.tmp ${CONFIGFILE}
  if [ -f ${PIDFILE} ]; then
    echo rehashing iroffer
    kill -USR2 `cat ${PIDFILE}`
  else
    echo no iroffer running
  fi
fi

exit 0
