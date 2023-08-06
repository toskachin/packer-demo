#!/bin/bash
#==============================================================================#

Usage() {
    cat <<EOF 1>&2

Usage: $0 [-h] [-f]
       -h this message

Description:
   call Vendor Specific Motd update

EOF
exit 1
}

#------------------------------------ Main ------------------------------------
# save my location
DIR="`dirname $0`"
ME="`basename $0 .sh`"
PIDFILE=${VARTMP}/${ME}.pid

if [ "$DIR" == "." ]; then
    DIR="`pwd`"
fi

# parse argument list
while [ $# -ge 1 ]; do
case $1 in
  -h) Usage;;
   *) echo "unknown: $1"; Usage; break;;
esac
shift
done

# set umask just in case.
umask 002

# Save System Manufacture
_MFG=$( dmidecode -s system-manufacturer )
case $_MFG in
  Dell*) /usr/local/bin/update_dell.motd.sh;;
    HP*) /usr/local/bin/update_hp.motd.sh;;
  VMwa*) /usr/local/bin/update_vmware.motd.sh;;
  Amazon*) /usr/local/bin/update_aws.motd.sh;;
esac
