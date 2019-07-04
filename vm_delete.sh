#!/bin/bash

while getopts "v:" opt; do
    case $opt in
        v)
            VIRT=${OPTARG}
            ;;
        \?)
            printf "\n-v VM Name" >&2
            exit 1
            ;;
    esac
done

echo "--------------------------------------------------------------------------------------------------------------"
cat << "EOF"


██╗   ██╗███╗   ███╗    ██████╗ ███████╗██╗     ███████╗████████╗ █████╗ 
██║   ██║████╗ ████║    ██╔══██╗██╔════╝██║     ██╔════╝╚══██╔══╝██╔══██╗
██║   ██║██╔████╔██║    ██║  ██║█████╗  ██║     █████╗     ██║   ███████║
╚██╗ ██╔╝██║╚██╔╝██║    ██║  ██║██╔══╝  ██║     ██╔══╝     ██║   ██╔══██║
 ╚████╔╝ ██║ ╚═╝ ██║    ██████╔╝███████╗███████╗███████╗   ██║   ██║  ██║
  ╚═══╝  ╚═╝     ╚═╝    ╚═════╝ ╚══════╝╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
EOF

VM_NAME_ARRAY=()
    printf "\n\n"
    printf "%-40s %-80s\n" "VM Name" "Image"
    echo "--------------------------------------------------------------------------------------------------------------"
    for VM in $(virsh list --all | sort -t_ -V -k2 | grep $VIRT | awk '{print $2}'); do
        VM_NAME_ARRAY+=($VM)
        IMAGE=`virsh dumpxml $VM | grep 'source file' | cut -c 21- | rev | cut -c 4- | rev`
        printf "%-40s %-80s\n" "$VM" "$IMAGE"
        ((I++))
    done
    printf "\n\n"

read -p "Press Enter to select VM to delete:"
echo ""

whiptail_args=(
  --separate-output
  --title "Select VM to Delete:"
  --checklist "Select VM to Delete:"
  30 200 "${#VM_NAME_ARRAY[@]}"  # note the use of ${#arrayname[@]} to get count of entries
)

i=0
for db in "${VM_NAME_ARRAY[@]}"; do
  whiptail_args+=( "$((++i))" "$db" )
  if [[ $db = $db ]]; then    # only RHS needs quoting in [[ ]]
    whiptail_args+=( "off" )
  fi
done

# collect both stdout and exit status
# to grok the file descriptor switch, see https://stackoverflow.com/a/1970254/14122
whiptail_out=$(whiptail "${whiptail_args[@]}" 3>&1 1>&2 2>&3); whiptail_retval=$?

# Convert the whiptail string to an arrary
SAVEIFS=$IFS   # Save current IFS
IFS=$'\n'      # Change IFS to new line
whiptail_out=($whiptail_out) # split to array $names
IFS=$SAVEIFS   # Restore IFS

VM=""
SOURCE_FILE=""

for i in "${whiptail_out[@]}" ; do
  i="$(($i-1))"
  VM="${VM_NAME_ARRAY[$i]}"
  SOURCE_FILE=`virsh dumpxml $VM | grep 'source file' | cut -c 21- | rev | cut -c 4- | rev`

  echo "--------------------------------------------------------------------------------------------------------------"
  echo ""
  printf "VM Name: $VM\n"
  printf "Source file: $SOURCE_FILE\n\n"
  printf "Destroying $VM\n"
  virsh destroy $VM 2>/dev/null
  sleep 1

  printf "Deleting Snapshots:\n"
  for SNAPSHOT in `virsh snapshot-list --domain $VM | sed -n 3p | cut -d" " -f2`; do
    echo $SNAPSHOT
    echo $VM
    virsh snapshot-delete $VM --snapshotname $SNAPSHOT
  done
  
  printf "Undefining $VM\n"
  virsh undefine $VM

  printf "Deleting source file: $SOURCE_FILE\n\n"
  rm -rf $SOURCE_FILE

  printf "$VM Deleted\n\n"
done