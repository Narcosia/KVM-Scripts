#!/bin/bash

tc qdisc add dev virbr_hal_0 ingress

tc filter add dev virbr_hal_0 parent ffff: protocol ip u32 match u8 0 0 action mirred egress mirror dev virbr_hal_m

tc qdisc replace dev virbr_hal_0 parent root prio

id=`tc qdisc show dev virbr_hal_0 | grep prio | awk '{ print $3}'`

tc filter add dev virbr_hal_0 parent $id protocol ip u32 match u8 0 0 action mirred egress mirror dev virbr_hal_m