#!/bin/bash

VMID=0
STORAGE_DEST=""
HOST_DEST=""

while getopts ":i:s:h" opt
do
  case $opt in
    i ) VMID=$OPTARG ;;
    s ) STORAGE_DEST=$OPTARG ;;
    h ) HOST_DEST=$OPTARG ;;
    \? ) echo "Error"
      exit 1 ;;
    : ) echo "Option -$OPTARG requires an argument"
      exit 1 ;;
  esac
done

DISCOS="$(qm config $VMID | egrep "^virtio[0-9]|^scsi[0-9]" | awk '{print $1}' | tr -d ":")"

for i in $DISCOS; do
  qm move_disk $VMID $i $STORAGE_DEST --delete
done
qm migrate $VMID $HOST_DEST --online
