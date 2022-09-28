#!/bin/bash
SCRIPT_DIR=$( basename -- "$0"; )
CONFIG="$SCRIPT_DIR/env.config"
DATE=`date`

SSH="ssh $MIKROTIK_USER@$MIKROTIK_HOST "
SSH_OUTPUT=$(eval $SSH "/ip/dhcp-server/lease print")

echo "$SSH_OUTPUT"
