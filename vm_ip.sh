#!/bin/bash

while getopts ":n:" opt; do
    case $opt in
        n)
            VNET=${OPTARG}
            ;;
        \?)
            printf "Invalid option: -$OPTARG\n\n" >&2
            exit 1
            ;;
    esac
done

# read -p "Enter Network: " VNET
printf "\n\n"
printf "%-40s %-20s %-20s %-30s\n" "VM Name" "IP Address" "MAC Address" "Hostname"
echo "--------------------------------------------------------------------------------------------------------------"
for vm in $(virsh list | grep running | awk '{print $2}'); do 
    if [[ $(virsh dumpxml $vm | grep "$VNET") ]]; then
        mac=`virsh dumpxml $vm | grep -e "$VNET" -e "mac address" | sed -n 1p | awk -F"'" '{print $2}'`
        ip=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $5}'`
        host=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $6}'`
        printf "%-40s %-20s %-20s %-30s\n" "$vm" "$ip" "$mac" "$host"
    fi
done
printf "\n\n"
