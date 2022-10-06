# -------------------
# -- Shared Functions
# -------------------

_debug () {
    if [[ $DEBUG_API != "1" ]]; then
      if [[ $DEBUG == "1" ]]; then
          echo -e "${CYAN}** DEBUG: $@${ECOL}"
      fi
    fi
}