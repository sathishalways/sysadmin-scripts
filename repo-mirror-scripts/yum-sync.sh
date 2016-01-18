#!/bin/bash

# Change BASE to fit your needs
BASE='/export/data/repo'
RSYNC='rsync://mirror.mit.edu'
RSYNCOPTS='-vrtlp'

# Repo Functions
exclude_base () {
if [ -d /etc/sync ]
    then 
        exit 0
    else 
        mkdir /etc/sync
fi
}

exclude_centos () {
exclude_base
cat > /etc/sync/centos-exclude << EOF
2
2.*
3
3.*
4
4.*
EOF
}

## CentOS Mirror
centos_mirror () {
if [ -a /etc/sync/centos-exclude ]
    then 
        centos_mirror
    else 
        exclude_centos
fi
rsync $RSYNCOPTS --exclude-from='/etc/sync/centos-exclude' $RSYNC/centos/ $BASE/centos/
}

## EPEL Mirror
epel_mirror () {
rsync $RSYNCOPTS $RSYNC/epel/ $BASE/epel/ 
}
