#!/bin/bash

# update the package list
apt-get update
apt-get install -y dnsutils
apt-get update
apt-get install rsync

# define the source and destination paths
SRC="/data/backups"
DEST1="user@$(dig +short machine1):/data/backups"
DEST2="user@$(dig +short machine2):/data/backups"
DEST3="user@$(dig +short machine3):/data/backups"

# sync the file to all three machines with bandwidth limit of 10MB
rsync --bwlimit=10m "$SRC" "$DEST1"
rsync --bwlimit=10m "$SRC" "$DEST2"
rsync --bwlimit=10m "$SRC" "$DEST3"
