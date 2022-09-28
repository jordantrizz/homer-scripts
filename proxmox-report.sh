#!/bin/bash
SCRIPT_DIR=$( basename -- "$0"; )
CONFIG="$SCRIPT_DIR/env.config"
DATE=`date`

# -- check for env.cnf
if [[ -a $CONFIG ]]; then
	source $CONFIG
else
	echo "Error: can't find config at $CONFIG"
	exit 1
fi

# -- scmd sshe command
scmd () {
	ssh $PROXMOX_USER@$PROXMOX_HOST "$@"
}

# -- main loop
QM_LIST=$(ssh root@$HOST "qm list")
QM_IDS=$(echo "$QM_LIST" | awk {' print $1 '} | grep -v 'VMID')
QM_NAMES=$(echo "$QM_LIST" | awk {' print $2 '} | grep -v 'NAME')
QM_STATUS=$(echo "$QM_LIST" | awk {' print $3 '} | grep -v 'STATUS')

readarray -t QM_IDS <<< "$QM_IDS"
readarray -t QM_NAMES <<< "$QM_NAMES"
readarray -t QM_STATUS <<< "$QM_STATUS"

# New Status
echo '<div id="pm_status" style="color: white;"><pre>'
echo "ID     Name                      Status       Network"
#printf '%-10s %-10s %-10s %-10s'
i=0
for VM_ID in ${QM_IDS[@]}; do
	QM_NETWORK=$(scmd "qm guest cmd $VM_ID network-get-interfaces 2>&1" )	
	#	echo " -- Network Interfaces
	# qm guest cmd 105 network-get-interfaces
#	echo "${QM_IDS[$i]}"
#	echo ""
	printf "%-6s %-25s %-12s %s\n" ${QM_IDS[$i]} ${QM_NAMES[$i]} ${QM_STATUS[$i]} "$QM_NETWORK"
	((i=i+1))
done
echo ""
echo "Date: $DATE"
echo '</pre></div>'