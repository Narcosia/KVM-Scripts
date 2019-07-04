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
echo "--------------------------------------------------------------------------------------------------------------------------------"
printf "%-40s ;%-20s ;%-40s ;%-30s\n" "Hostname" "IP Address" "Splunk Index" "Hacker"
for vm in $(virsh list | sort -t_ -V -k2 | grep running | awk '{print $2}'); do 
    if [[ $(virsh dumpxml $vm | grep "$VNET") ]]; then
        mac=`virsh dumpxml $vm | grep -e "$VNET" -e "mac address" | sed -n 1p | awk -F"'" '{print $2}'`
        ip=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $5}' | sed 's/...$//'`
        host=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $6}'`
        printf "%-40s ;%-20s ;%-40s ;%-30s\n" "$host.hal.org.nz" "$ip" "index=vulns host=\"$host\"" "Anonymous"
    fi
done
printf "\n\n"
