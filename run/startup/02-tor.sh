#!/bin/sh
## Startup script for tor.

###############################################################################
# Environment
###############################################################################

TOR_DATA="/data/tor"
TOR_CONFIG="/etc/tor/torrc"
TOR_COOKIE="/var/lib/tor"
TOR_LOG="/var/log/tor/notice.log"

###############################################################################
# Script
###############################################################################

TOR_PID=`pgrep tor`

if [ -z "$TOR_PID" ]; then

  ## If missing, create tor services path.
  if [ ! -d "$TOR_DATA/services" ]; then
    echo "Adding persistent data directory for tor ..."
    mkdir -p -m 700 $TOR_DATA/services
  fi

  ## If missing, create tor cookie path.
  if [ ! -d "$TOR_COOKIE" ]; then
    echo "Adding cookie directory for tor ..."
    mkdir -p -m 700 $TOR_COOKIE
  fi

  ## Make sure permissions are correct.
  echo "Enforcing permissions on tor directories ..."
  chown -R tor:tor $TOR_DATA
  chown -R tor:tor $TOR_COOKIE

  ## Start tor then tail the logfile to search for the completion phrase.
  echo "Starting tor process..."
  tor -f $TOR_CONFIG; tail -f $TOR_LOG | while read line; do
    echo "$line" && echo "$line" | grep "Bootstrapped 100%"
    if [ $? = 0 ]; then echo "Tor circuit initialized!" && exit 0; fi
  done

else

  echo "Tor daemon is running under PID: $TOR_PID"

fi