#!/bin/bash
[ -z $BASH ] && { exec bash "$0" "$@" || exit; }
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CONFIG="$SCRIPT_DIR/env.cfg"
DATE=`date`

# -- check for env.cnf
if [[ -a $CONFIG ]]; then
    source $CONFIG
else
    echo "Error: can't find config at $CONFIG"
    exit 1
fi

# -- ssh command
scmd () {
    eval "ssh ${MIKROTIK_USER}@${MIKROTIK_HOST} $@"
}

SSH_OUTPUT=$(scmd /ip/dhcp-server/lease print)


echo '<div id="pm_status" style="color: white;"><pre>'
echo "$SSH_OUTPUT"
echo ""
echo "Date: $DATE"
echo '</pre></div>'