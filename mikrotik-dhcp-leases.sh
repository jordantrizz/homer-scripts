#!/bin/bash
HOST="192.168.80.1"
USER="admin"
SSH="ssh $USER@$HOST "
SSH_OUTPUT=$(eval $SSH "/ip/dhcp-server/lease print")

echo "$SSH_OUTPUT"
