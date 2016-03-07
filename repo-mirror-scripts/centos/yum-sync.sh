#!/bin/bash

# Change BASE to fit your needs
BASE='/seamnt/prd101/ossmirror/html/repo'
RSYNC='rsync://mirror.mit.edu'
RSYNCOPTS='-vrtlp'

## CentOS Mirror
centos_mirror () {
rsync $RSYNCOPTS --exclude-from='/etc/sync/centos-exclude' $RSYNC/centos/ $BASE/centos/
}

## EPEL Mirror
epel_mirror () {
rsync $RSYNCOPTS $RSYNC/epel/ $BASE/epel/
}

case $1 in
    centos)
        centos_mirror
        ;;
    epel)
        epel_mirror
        ;;
    *)
        echo "Usage: centos|epel"
        echo "Customize BASE in this script"
        ;;
esac

