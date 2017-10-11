#!/bin/sh
#$1 - 0,1,2,3,4 (everywhere to customers)
for i in `seq 0 4`; do 
    case ${i} in
        0) nei_t='everywhere' ;;
        1) nei_t='uplink' ;;
        2) nei_t='ix' ;;
        3) nei_t='peer' ;;
        4) nei_t='customer' ;;
        *) exit 255 ;;
    esac
    for j in 0 1 2 4 7 9; do 
        echo "\
no ip community-list standard cl-${nei_t}-$j
ip community-list standard cl-${nei_t}-$j permit 650${i}${j}:0
ip community-list standard cl-${nei_t}-$j permit 64499:650${i}${j}"
    done
done
for i in `seq 0 5`; do 
    case ${i} in
        0) nei_t='anypeer' ;;
        1) nei_t='uplink' ;;
        2) nei_t='ix' ;;
        3) nei_t='peer' ;;
        4) nei_t='customer' ;;
        5) nei_t='dec' ;;
        *) exit 255 ;;
    esac
    echo "\
no ip community-list standard cl-from-${nei_t}
ip community-list standard cl-from-${nei_t} permit 64499:649${i}0
ip community-list standard cl-from-${nei_t} permit 649${i}0:0"
done
for i in `seq 0 4`; do 
    case ${i} in
        0) loc_t='anyloc' ;;
        1) loc_t='world' ;;
        2) loc_t='ua' ;;
        3) loc_t='ru' ;;
        4) loc_t='dn' ;;
        *) exit 255 ;;
    esac
    echo "\
no ip community-list standard cl-from-${loc_t}
ip community-list standard cl-from-${loc_t} permit 64499:648${i}0
ip community-list standard cl-from-${loc_t} permit 648${i}0:0"
done					   
echo "\
no ip community-list expanded cl-4-delete-on-out
!may be not deleted
ip community-list expanded cl-4-delete-on-out deny 65535:65535
!may be deleted
ip community-list expanded cl-4-delete-on-out permit 65500:1[0-9]*
ip community-list expanded cl-4-delete-on-out permit 6451[2-9]:[0-9]+
ip community-list expanded cl-4-delete-on-out permit 645[2-9][0-9]:[0-9]+
ip community-list expanded cl-4-delete-on-out permit 64[6-9][0-9][0-9]:[0-9]+
ip community-list expanded cl-4-delete-on-out permit 65[0-4][0-9][0-9]:[0-9]+
ip community-list expanded cl-4-delete-on-out permit 655[0-2][0-9]:[0-9]+
ip community-list expanded cl-4-delete-on-out permit 6553[0-5]:[0-9]+"

echo "\
no ip community-list standard cl-default-only
ip community-list standard cl-default-only permit 64499:0"

echo "\
no ip community-list standard cl-as64499
ip community-list standard cl-as64499 permit 64499:65050
no ip community-list expanded cl-as64499-all
ip community-list expanded cl-as64499-all permit 6505[0-2479]:0
ip community-list expanded cl-as64499-all permit 64499:6505[0-2479]"

echo "\
no ip community-list standard cl-customer
ip community-list standard cl-customer permit 64499:65040
no ip community-list expanded cl-customer-all
ip community-list expanded cl-customer-all permit 6504[0-2479]:0
ip community-list expanded cl-customer-all permit 64499:6504[0-2479]"

echo "\
no ip community-list standard cl-peer
ip community-list standard cl-peer permit 64499:65030
no ip community-list expanded cl-peer-all
ip community-list expanded cl-peer-all permit 6503[0-2479]:0
ip community-list expanded cl-peer-all permit 64499:6503[0-2479]"

echo "\
no ip community-list standard cl-ix
ip community-list standard cl-ix permit 64499:65020
no ip community-list expanded cl-ix-all
ip community-list expanded cl-ix-all permit 6502[0-2479]:0
ip community-list expanded cl-ix-all permit 64499:6502[0-2479]"

echo "\
no ip community-list standard cl-inet
ip community-list standard cl-inet permit 64499:65010
no ip community-list expanded cl-inet-all
ip community-list expanded cl-inet-all permit 6500[0-2479]:0
ip community-list expanded cl-inet-all permit 64499:6500[0-2479]"

echo "\
no ip community-list standard cl-everywhere
ip community-list standard cl-everywhere permit 64499:65000
no ip community-list expanded cl-everywhere-all
ip community-list expanded cl-everywhere-all permit 6500[0-247]:0
ip community-list expanded cl-everywhere-all permit 64499:6500[0-247]"

echo "\
no ip community-list standard cl-as6886-own-prefixes
no ip community-list standard cl-as6886-dn-prefixes
no ip community-list standard cl-as6886-ua-prefixes
ip community-list standard cl-as6886-own-prefixes permit 6886:6886
ip community-list standard cl-as6886-dn-prefixes permit 6886:65000
ip community-list standard cl-as6886-ua-prefixes permit 6886:65100"
