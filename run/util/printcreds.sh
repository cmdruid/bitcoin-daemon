#!/bin/sh
## Print current RPC credentials.

###############################################################################
# Environment
###############################################################################

TORDATA_PATH="/data/tor"
RPCAUTH_PATH="/data/bitcoin"

###############################################################################
# Script
###############################################################################

printf "
===============================================================================
  Address: $(cat $TORDATA_PATH/services/rpc/hostname):8332
  Username: $(cat $RPCAUTH_PATH/rpcauth.conf | grep rpcuser | awk -F = '{print $2}')
  Password: $(cat $RPCAUTH_PATH/rpcauth.conf | grep rpcpass | awk -F = '{print $2}')
===============================================================================
\n"