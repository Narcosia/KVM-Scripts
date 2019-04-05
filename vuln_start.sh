#!/bin/bash

iptables-restore firewall_setup.conf

for vm in $(virsh list --all | grep vuln--- | awk '{print $2}'); do
    virsh start ${vm}
done
read -p "Wait for systems to boot: " Nothing

iptables-restore firewall_active.conf
