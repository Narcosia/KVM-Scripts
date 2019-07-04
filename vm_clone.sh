#!/bin/bash

while getopts "n:v:h:" opt; do
    case $opt in
        n)
            COUNT=${OPTARG}
            ;;
        v)
            VMNAME=${OPTARG}
            ;;
        h)
            VMTEMPLATENAME=${OPTARG}
            ;;
        \?)
            printf "\n-n Number\n-v VM Name" >&2
            printf "\n-h Name to start from\n\n"
            exit 1
            ;;
    esac
done

    if [[ $(virsh list | grep "$VMNAME") ]]; then
        virsh destroy $VMNAME
        sleep 10
    fi

echo "--------------------------------------------------------------------------------------------------------------"
for vm in $(seq 1 ${COUNT}); do
    virt-clone --original ${VMNAME} --name "${VMTEMPLATENAME}_${vm}" --auto-clone
done
printf "\n\n"
