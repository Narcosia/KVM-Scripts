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

    virsh destroy $host
    sleep 10
    virsh snapshot-revert ${host} --snapshotname ${host}_Initialized --running


