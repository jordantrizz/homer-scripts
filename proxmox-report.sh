#!/bin/bash
# -- run bash if invokved via sh
[ -z $BASH ] && { exec bash "$0" "$@" || exit; }
# -- Variables
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CONFIG="$SCRIPT_DIR/env.cfg"
DATE=ate +"%Y-%m-%d %T"

# -- check for env.cnf
if [[ -a $CONFIG ]]; then
	source $CONFIG
else
	echo "Error: can't find config at $CONFIG"
	exit 1
fi

# -- ssh command
scmd () {
  if [[ $PROXMOX_PASSWORD ]]; then
    eval "sshpass -p ${$PROXMOX_PASSWORD} ${PROXMOX_USER}@${PROXMOX_HOST} $@"
  else
	  eval "ssh ${PROXMOX_USER}@${PROXMOX_HOST} $@"
	fi
}

PROXMOX_UPTIME=$(scmd uptime)
PROXMOX_HOSTNAME=$(scmd hostname -af)

# -- main loop
QM_LIST=$(scmd "qm list")
QM_IDS=$(echo "$QM_LIST" | awk {' print $1 '} | grep -v 'VMID')
QM_NAMES=$(echo "$QM_LIST" | awk {' print $2 '} | grep -v 'NAME')
QM_STATUS=$(echo "$QM_LIST" | awk {' print $3 '} | grep -v 'STATUS')

readarray -t QM_IDS <<< "$QM_IDS"
readarray -t QM_NAMES <<< "$QM_NAMES"
readarray -t QM_STATUS <<< "$QM_STATUS"

# New Status
echo '<div id="pm_status" style="color: white;"><pre>'
echo "Host: $PROXMOX_HOSTNAME"
echo "Uptime: $PROXMOX_UPTIME"
echo "ID     Name                      Status       Network"
i=0
for VM_ID in ${QM_IDS[@]}; do
	QM_NETWORK=$(scmd "qm guest cmd $VM_ID network-get-interfaces 2>&1" )	
	#	echo " -- Network Interfaces
	# qm guest cmd 105 network-get-interfaces
	printf "%-6s %-25s %-12s %s\n" ${QM_IDS[$i]} ${QM_NAMES[$i]} ${QM_STATUS[$i]} "$QM_NETWORK"
	((i=i+1))
done
echo ""
echo "Date: $DATE"
echo '</pre></div>'