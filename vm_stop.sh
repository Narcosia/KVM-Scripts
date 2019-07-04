#!/bin/bash

for vm in $(virsh list --all | grep vuln--- | awk '{print $2}'); do
    virsh destroy ${vm}
done
