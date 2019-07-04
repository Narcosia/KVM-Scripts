#!/bin/bash

while getopts "n:i:v:h:dcf" opt; do
    case $opt in
        n)
            VNET=${OPTARG}
            ;;
        i)
            I=${OPTARG}
            I_Initial=$I
            ;;
        v)
            VIRT=${OPTARG}
            ;;
        h)
            HOSTNAME=${OPTARG}
            ;;
        d)
            OS="debian"
            ;;
        c)
            OS="centos"
            ;;
        f)
            OS="freebsd"
            ;;
        \?)
            printf "Invalid option: -$OPTARG\n" >&2
            printf "\n-n Virtual Network Name"
            printf "\n-v Virtual Machine Name"
            printf "\n-h Hostname to Change To"
            printf "\n-i Initial Hostname Number to Start From"
            printf "\n-d Debian"
            printf "\n-c CentOS"
            printf "\n-f FreeBSD"
            printf "\n\n"
            exit 1
            ;;
    esac
done

printf "$VIRT"
printf "$OS"


### Host Check ###
host_check (){
    printf "\n\n"
    printf "%-40s %-20s %-30s %-30s\n" "VM Name" "IP Address" "Current Hostname" "Updated Hostname"
    echo "--------------------------------------------------------------------------------------------------------------"
    for vm in $(virsh list | sort -t_ -V -k2 | grep $VIRT | awk '{print $2}'); do 
        if [[ $(virsh dumpxml $vm | grep "$VNET") ]]; then
            mac=`virsh dumpxml $vm | grep -e "$VNET" -e "mac address" | sed -n 1p | awk -F"'" '{print $2}'`
            ip=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $5}' | sed 's/.\{3\}$//'`
            host=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $6}'`
            printf "%-40s %-20s %-30s %-30s\n" "$vm" "$ip" "$host" "${HOSTNAME}-${I}.hal.org.nz"
            # echo "${HOSTNAME}_${I}"
            ((I++))
        fi
    done
    printf "\n\n"
}


### Commit Functions ###

# Debian #
host_commit_debian (){
    printf "Executing Debian based hostname change...\n"
    I=$I_Initial
    read -p "Commit Changes? Y/n : " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
        then
            for vm in $(virsh list | sort -t_ -V -k2 | grep $VIRT | awk '{print $2}'); do 
                if [[ $(virsh dumpxml $vm | grep "$VNET") ]]; then
                    mac=`virsh dumpxml $vm | grep -e "$VNET" -e "mac address" | sed -n 1p | awk -F"'" '{print $2}'`
                    ip=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $5}' | sed 's/.\{3\}$//'`
                    host=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $6}'`
                    printf "%-40s %-20s %-30s %-30s\n" "$vm" "$ip" "$host" "${HOSTNAME}-${I}"
                    hostname="${HOSTNAME}-${I}.hal.org.nz"
                    ssh -o StrictHostKeyChecking=no root@${ip} "echo $hostname > /etc/hostname; printf \[default\]\\n$hostname > /opt/splunkforwarder/etc/system/local/inputs.conf; nohup reboot now &>/dev/null & exit"
                    # echo "${HOSTNAME}_${I}"
                    ((I++))
                fi
            done
    fi
}


# CentOS #
host_commit_centos (){
    printf "Executing CentOS based hostname change...\n"
    I=$I_Initial
    read -p "Commit Changes? Y/n : " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
        then
            for vm in $(virsh list | sort -t_ -V -k2 | grep $VIRT | awk '{print $2}'); do 
                if [[ $(virsh dumpxml $vm | grep "$VNET") ]]; then
                    mac=`virsh dumpxml $vm | grep -e "$VNET" -e "mac address" | sed -n 1p | awk -F"'" '{print $2}'`
                    ip=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $5}' | sed 's/.\{3\}$//'`
                    host=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $6}'`
                    printf "%-40s %-20s %-30s %-30s\n" "$vm" "$ip" "$host" "${HOSTNAME}-${I}"
                    hostname="${HOSTNAME}-${I}.hal.org.nz"
                    ssh -o StrictHostKeyChecking=no root@${ip} "sed -i /DHCP_HOSTNAME/c\DHCP_HOSTNAME=$hostname /etc/sysconfig/network-scripts/ifcfg-eth0; sed -i /DHCP_HOSTNAME/c\DHCP_HOSTNAME=$hostname /etc/sysconfig/network-scripts/ifcfg-eth1; sed -i /DHCP_HOSTNAME/c\DHCP_HOSTNAME=$hostname /etc/sysconfig/network-scripts/ifcfg-eth2; printf NETWORKING=yes\\\nHOSTNAME=$hostname > /etc/sysconfig/network; printf \[default\]\\\n$hostname > /opt/splunkforwarder/etc/system/local/inputs.conf; nohup reboot now &>/dev/null & exit"
                    # echo "${HOSTNAME}_${I}"
                    ((I++))
                fi
            done
    fi
}

# FreeBSD #
host_commit_freebsd (){
    printf "Executing FreeBSD based hostname change...\n"
    I=$I_Initial
    read -p "Commit Changes? Y/n : " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
        then
            for vm in $(virsh list | sort -t_ -V -k2 | grep $VIRT | awk '{print $2}'); do 
                if [[ $(virsh dumpxml $vm | grep "$VNET") ]]; then
                    mac=`virsh dumpxml $vm | grep -e "$VNET" -e "mac address" | sed -n 1p | awk -F"'" '{print $2}'`
                    ip=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $5}' | sed 's/.\{3\}$//'`
                    host=`virsh net-dhcp-leases --network ${VNET} | grep $mac | awk '{print $6}'`
                    printf "%-40s %-20s %-30s %-30s\n" "$vm" "$ip" "$host" "${HOSTNAME}-${I}"
                    hostname="${HOSTNAME}-${I}"
                    hostname_fqdn="${HOSTNAME}-${I}.hal.org.nz"
                    printf "#!/bin/bash\n\nsed -i -e 's/^.*hostname.*$/hostname=\"$hostname\"/' /etc/rc.conf \n\n" > /root/scripts/kvm/temp_files/host_change_freebsd.sh
                    printf "sed -i -e 's/^.*127.0.0.1.*$/127.0.0.1    $hostname    $hostname_fqdn/' /etc/hosts \n\n" >> /root/scripts/kvm/temp_files/host_change_freebsd.sh
                    # printf "printf \"\[default\]\\\n$hostname\" > /opt/splunkforwarder/etc/system/local/inputs.conf" >> /root/scripts/kvm/temp_files/host_change_freebsd.sh
                    scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /root/scripts/kvm/temp_files/host_change_freebsd.sh root@${ip}:/root/
                    ssh -q -o StrictHostKeyChecking=no root@${ip} "chmod u+x /root/host_change_freebsd.sh; /bin/sh host_change_freebsd.sh; rm host_change_freebsd.sh"
                    rm /root/scripts/kvm/temp_files/host_change_freebsd.sh
                    ((I++))
                fi
            done
    fi
}

### MAIN ###

host_check
case $OS in 
    centos) 
        host_commit_centos
        ;;
    debian)
        host_commit_debian
        ;;
    freebsd)
        host_commit_freebsd
        ;;
esac