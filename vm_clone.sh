#!/bin/bash

while getopts "n:v:" opt; do
    case $opt in
        n)
            VNET=${OPTARG}
            ;;
        v)
            VMNAME=${OPTARG}
            ;;
        \?)
            printf "Invalid option: -$OPTARG\n\n" >&2
            exit 1
            ;;
    esac
done

echo "--------------------------------------------------------------------------------------------------------------"
for vm in $(seq 1 ${VNET}); do
    if [[ $(virsh list | grep "$VMNAME") ]]; then
        virsh destroy $VMNAME
        sleep 5
    fi
    virt-clone --original ${VMNAME} --name "${VMNAME}_${vm}" --auto-clone
done
printf "\n\n"
