#!/bin/sh

#$1 - 0,1,2,3,4 (everywhere to customers)
# 0 - everywhere
# 1 - uplink
# 2 - ix
# 3 - peer
# 4 - customer

echo '\
no ip prefix-list pl-example-subnet
ip prefix-list pl-example-subnet seq 5 permit 192.168.0.0/16 le 24
ip prefix-list pl-example-subnet seq 10 permit 172.20.38.0/23 le 24
!
no ip prefix-list pl-default
ip prefix-list pl-default seq 5 permit 0.0.0.0/0 le 24
!
no ip prefix-list pl-default-only
ip prefix-list pl-default-only seq 5 permit 0.0.0.0/0
'
#-------common-cl--------
./common-cl-cisco-ios.sh

#-------example-dn-cust-------
bgpq3 -PAl pl-example-dn AS64498
bgpq3 -3f 64498 -l 101 AS64498
./cl-rm-cisco-ios-out.sh example-dn 4 64498
./cl-rm-cisco-ios-in.sh example-dn 4 4 64498 pl-example-dn 101
