#!/bin/bash
set -e

IMAGENAME=${1:-${IMAGENAME}}
LOCKNAME=${2:-${HOSTNAME}}
LOCKID=${3:-${LOCKID}}

function usage() {
   echo "$0 <pool/image> [lockName [lockId]]"
   exit 255
}

# Make sure the image name is set
if [ ! -n "$IMAGENAME" ]; then
   usage
fi

# Make sure the lock name is set
if [ ! -n "$LOCKNAME" ]; then
   usage
fi

# If we were given an ETCD_LOCKID_KEY, use that to find
# the lock id
if [ -n "$ETCD_LOCKID_KEY" ]; then
   LOCKID=$(etcdctl get $ETCD_LOCKID_KEY)
   etcdctl rm $ETCD_LOCKID_KEY
fi

# If we do not have a LOCKID, die
if [ ! -n "$LOCKID" ]; then
   echo "No LOCKID found"
   exit 2
fi

# Release the lock
rbd lock remove $IMAGENAME $LOCKNAME $LOCKID
if [ $? -ne 0 ]; then
   echo "Failed to release lock"
   exit 1
fi

exit 0
