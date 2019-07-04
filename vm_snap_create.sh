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
    exec 3>&2
    exec 2> /dev/null
    virsh snapshot-delete --domain ${vm} --snapshotname ${vm}_Initialized
    exec 2>&3
    printf "Creating snapshot for ${vm}\n"
    virsh snapshot-create-as --domain ${vm} --name ${vm}_Initialized
    virsh snapshot-info --domain ${vm} --snapshotname ${vm}_Initialized
done
