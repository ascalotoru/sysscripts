#!/bin/bash

VMID=0
STORAGE_DEST=""
HOST_DEST=""

help(){
  echo "Moves VM disks to shared storage and then migrate to another host"
  echo "Usage:"
  echo "-i    VMID"
  echo "-s    Destination storage"
  echo "-h    Destination host. If set migrate the VM to the destination host."
  echo "Example:"
  echo "$0 -i 123 -s zfs_ssd -h proxmox02"
}

migrate(){
  qm migrate $VMID $HOST_DEST --online
}


while getopts "i:s:h:" opt
do
  case $opt in
    i ) VMID=$OPTARG ;;
    s ) STORAGE_DEST=$OPTARG ;;
    h ) HOST_DEST=$OPTARG ;;
    \? ) echo "Error"
        help
      exit 1 ;;
    # : ) echo "Option -$OPTARG requires an argument"
    #   help
    #   exit 1 ;;
  esac
done

DISCOS="$(qm config $VMID | egrep "^virtio[0-9]|^scsi[0-9]" | awk '{print $1}' | tr -d ":")"

for i in $DISCOS; do
  qm move_disk $VMID $i $STORAGE_DEST --delete
done
sleep 2
if [ ! -z $HOST_DEST ]; then
  migrate
fi

