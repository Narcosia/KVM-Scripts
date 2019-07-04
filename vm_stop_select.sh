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



for vm in $(virsh list --all | grep vuln--- | grep ${host} | awk '{print $2}'); do
    virsh destroy ${vm}
done
