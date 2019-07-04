#!/bin/bash

while getopts ":i:" opt; do
    case $opt in
        i)
            I=${OPTARG}
            I_Initial=$I
            ;;
        \?)
            printf "Invalid option: -$OPTARG\n" >&2
            printf "\n-n Virtual Network Name"
            printf "\n-v Virtual Machine Name"
            printf "\n-h Hostname to Change To"
            printf "\n-i Initial Hostname Number to Start From\n\n"
            exit 1
            ;;
    esac
done

    ip=10.100.0.20

    echo "Executing..."
    I=$I_Initial
    HOSTNAME="kali"
            hostname="${HOSTNAME}-${I}.hal.org.nz"

            scp net_config.txt root@${ip}:/etc/network/interfaces
            ssh -oStrictHostKeyChecking=no root@${ip} "hostnamectl set-hostname $hostname; nohup systemctl restart networking &>/dev/null & exit"
            # nohup reboot now &>/dev/null & exit