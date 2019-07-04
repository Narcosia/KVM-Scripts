#!/bin/bash
while getopts ":n:" opt; do
    case $opt in
        n)
            host=${OPTARG}
            ;;
        \?)
            printf "Invalid option: -$OPTARG\n\n" >&2
            exit 1
            ;;
    esac
done

# iptables-restore firewall_setup.conf



for vm in $(virsh list --all | grep vuln--- | grep ${host} | awk '{print $2}'); do
    virsh start ${vm}
done
#read -p "Wait for systems to boot: " Nothing

# iptables-restore firewall_active.conf
