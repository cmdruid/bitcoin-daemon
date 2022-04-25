#!/bin/sh
## Startup script for dash.

###############################################################################
# Environment
###############################################################################

LOGS="
/var/log/tor/notice.log,
/var/log/bitcoin/debug.log
"

###############################################################################
# Methods
###############################################################################

print_log_str() {
  echo "$(
    for log in $(echo $LOGS | tr ',' '\n'); do 
      echo $log
    done | tr '\n' ' '
  )"
}

###############################################################################
# Script
###############################################################################

## Print RPC Credentials for connecting.
sh $WORKDIR/util/printcreds.sh

## Start tailing log files.
tail -f `print_log_str`