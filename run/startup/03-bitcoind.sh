#!/bin/sh
## Start script for bitcoind.

###############################################################################
# Environment
###############################################################################

DATA_DIR="/data/bitcoin"
CONF_DIR="/root/.bitcoin/bitcoin.conf"
BITCOIND_LOG="/var/log/bitcoin/debug.log"

###############################################################################
# Script
###############################################################################

BITCOIND_PID=`pgrep bitcoind`

if [ -z "$BITCOIND_PID" ]; then

  ## If missing, create bitcoin data path.
  if [ ! -d "$DATA_DIR" ]; then
    echo "Adding bitcoind data directories ..."
    mkdir $DATA_DIR
  fi

  ## If missing, generate rpcauth credentials.
  if [ ! -e "$DATA_DIR/rpcauth.conf" ]; then
    echo "Generating RPC credentials ..."
    SILENT=1 $WORKDIR/util/rpcauth.sh bitcoin
    mv rpcauth.conf $DATA_DIR
  fi

  ## Download and unpack the blockchain snapshot.
  
  if [ ! -d "$DATA_DIR/blocks" ]; then
    SNAPSHOT=`ls /snapshot | grep .zip`
    NETWORK=`cat /root/.bitcoin/bitcoin.conf | grep -P ^chain`
    if [ -n "${SNAPSHOT}" ] && [ -n "$(echo $NETWORK | grep main)" ]; then
      echo "Unpacking snapshot file ..."
      unzip -q /snapshot/*.zip -d $DATA_DIR
    fi
  fi

  ## Start bitcoind then tail the logfile to search for the completion phrase.
  bitcoind; tail -f $BITCOIND_LOG | while read line; do
    echo "$line" && echo "$line" | grep "init message: Done loading"
    if [ $? = 0 ]; then echo "Bitcoin daemon initialized!" && exit 0; fi
  done

else

  echo "Bitcoin daemon is running under PID: $BITCOIND_PID"

fi