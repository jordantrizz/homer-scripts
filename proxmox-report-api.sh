#!/bin/bash
# ------------------------------
# Get Proxomxox status using API
# ------------------------------
# -- run bash if invokved via sh
[ -z $BASH ] && { exec bash "$0" "$@" || exit; }

# -- Variables
VERSION="0.0.1"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CONFIG="${SCRIPT_DIR}/env.cfg"
DATE=$(date)
OPTIONS=""
PING_CHECK="1"
USAGE=\
"
proxmox-report-api.sh <options> <cmd>
  Options:
    -d             - Debug on.
    -dapi          - Output API debug.

  Command:
    test           - Test connection.
    nodes          - List nodes

Version: $VERSION
WARNING: This doesn't work!
"

# -- Includes
source "${SCRIPT_DIR}/functions.sh"

# ----------------
# -- Parse options
# ----------------
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -d|--debug)
    DEBUG="1"
    OPTIONS+="--debug=1 "
    shift # past argument
    ;;
    -dapi|--debug-api)
    DEBUG_API="1"
    OPTIONS+="--debug-api=1 "
    shift # past argument
    ;;
    -np|--noping)
    PING_CHECK="0"
    OPTIONS+="--ping=0 "
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# ---------
# -- Checks
# ---------
preflight_checks () {
  # -- check for env.cnf
  if [[ -e $CONFIG ]]; then
    source "${CONFIG}"
  else
    echo "Error: can't find config at $CONFIG"
    exit 1
  fi

  # -- check for ${PROXMOXAPI_USER} and ${PROXMOXAPI_PASS}
  if [[ ! ${PROXMOXAPI_USER} ]] || [[ ! ${PROXMOXAPI_PASS} ]]; then
    echo "Error: \${PROXMOXAPI_USER} and \${PROXMOXAPI_PASS} not defined in env.cfg"
    exit 1
  fi

  # -- confirm host is online
  _debug "Running -- ping -W2 -c 1 ${PROXMOX_HOST}"
  if [[ $PING_CHECK == "1" ]]; then
    if ping -W 2 -c 1 ${PROXMOX_HOST} >/dev/null; then
      _debug "Proxmox host online!"
    else
      echo "Can't ping Proxmox host ${PROXMOX_HOST}, is it online?"
      exit 1
    fi
  fi
}

# ------------
# -- Functions
# ------------
# -- usage
usage () {
  echo "$USAGE"
}

# -- pm_api_auth command
pm_api_auth () {
  local PM_API_OUTPUT=$(curl -s https://${PROXMOX_HOST}:8006/api2/json/access/ticket -k -d 'username='"${PROXMOXAPI_USER}"'@pam&password='"${PROXMOXAPI_PASS}"'')
  if [[ $DEBUG_API == "1" ]]; then echo "$PM_API_OUTPUT" > $SCRIPT_DIR/jq.out; fi
  PM_API_TICKET=$(echo "$PM_API_OUTPUT" | jq -r '.data["ticket"]')
  PM_API_CSRF=$(echo "$PM_API_OUTPUT" | jq -r '.data["CSRFPreventionToken"]')
  _debug "PM_API_TICKET = $PM_API_TICKET"
  _debug "PM_API_CSRF = $PM_API_CSRF"
}

# -- pm_api_curl
pm_api_curl () {
  CMD1="$1"
  CMD2="$2"
  CMD3="$3"
  _debug "Running pm_api_curl with $CMD1"
  PM_CURL_CMD="-s -k -b PVEAuthCookie=${PM_API_TICKET}"
  _debug "curl ${PM_CURL_CMD} https://${PROXMOX_HOST}:8006/api2/json/${CMD}1"
  CURL_OUT=$(curl ${PM_CURL_CMD} https://${PROXMOX_HOST}:8006/api2/json/${CMD1})
  echo $CURL_OUT | jq
  echo ""
}

# -- pm_api_test
pm_api_test () {
  echo "Running API Test"
	pm_api_curl
}

# -- pm_api_nodes
pm_api_nodes () {
	pm_api_curl nodes
}

# -- run proxmox api cmd
pm_api_list () {
  pm_api_curl list
  echo "List VM's"
}

# -------
# -- Main
# -------

_debug "Running with options ${OPTIONS}"
_debug "Doing preflight_checks"
preflight_checks

_debug "Get authentication from proxmox host"
pm_api_auth

CMD="$1"
if [[ -n "$CMD" ]]; then
  echo "Doing $CMD"
  pm_api_test
else
  usage
fi