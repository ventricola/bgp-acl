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
delete policy-options community cl-${nei_t}-$j
set policy-options community cl-${nei_t}-$j members \"^(650${i}${j}:0)|(64499:650${i}${j})$\""
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
delete policy-options community cl-from-${nei_t}
set policy-options community cl-from-${nei_t} members \"^(64499:649${i}0)|(649${i}0:0)$\""
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
delete policy-options community cl-from-${loc_t}
set policy-options community cl-from-${loc_t} members \"^(64499:648${i}0)|(648${i}0:0)$\""
done
echo "\
delete policy-options community cl-4-delete-on-out
#65535:65535 may be not deleted
set policy-options community cl-4-delete-on-out members \"^65500:1[0-9]*$\"
set policy-options community cl-4-delete-on-out members \"^6451[2-9]:[0-9]+$\"
set policy-options community cl-4-delete-on-out members \"^645[2-9][0-9]:[0-9]+$\"
set policy-options community cl-4-delete-on-out members \"^64[6-9][0-9][0-9]:[0-9]+$\"
set policy-options community cl-4-delete-on-out members \"^65[0-4][0-9][0-9]:[0-9]+$\"
set policy-options community cl-4-delete-on-out members \"^655[0-2][0-9]:[0-9]+$\"
set policy-options community cl-4-delete-on-out members \"^6553[0-4]:[0-9]+$\"
set policy-options community cl-4-delete-on-out members \"^65535:[0-57-9]+$\"
set policy-options community cl-4-delete-on-out members \"^65535:65[0-4][0-9]+$\"
set policy-options community cl-4-delete-on-out members \"^65535:655[0-2][0-9]$\"
set policy-options community cl-4-delete-on-out members \"^65535:6553[0-4]$\""

echo "\
delete policy-options community cl-default-only
set policy-options community cl-default-only members \"^64499:0$\""

echo "\
delete policy-options community cl-as64499
set policy-options community cl-as64499 members \"^64499:65050$\"
delete policy-options community cl-as64499-all
set policy-options community cl-as64499-all members \"^(6505[0-2479]:0)|(64499:6505[0-2479])$\""

echo "\
delete policy-options community cl-customer
set policy-options community cl-customer members \"^64499:65040$\"
delete policy-options community cl-customer-all
set policy-options community cl-customer-all members \"^(6504[0-2479]:0)|(64499:6504[0-2479])$\""
echo "\
delete policy-options community cl-peer
set policy-options community cl-peer members \"^64499:65030$\"
delete policy-options community cl-peer-all
set policy-options community cl-peer-all members \"^(6503[0-2479]:0)|(64499:6503[0-2479])$\""

echo "\
delete policy-options community cl-ix
set policy-options community cl-ix members \"^64499:65020$\"
delete policy-options community cl-ix-all
set policy-options community cl-ix-all members \"^(6502[0-2479]:0)|(64499:6502[0-2479])$\""

echo "\
delete policy-options community cl-inet
set policy-options community cl-inet members \"^64499:65010$\"
delete policy-options community cl-inet-all
set policy-options community cl-inet-all members \"^(6501[0-2479]:0)|(64499:6501[0-2479])$\""

echo "\
delete policy-options community cl-everywhere
set policy-options community cl-everywhere members \"^64499:65000$\"
delete policy-options community cl-everywhere-all
set policy-options community cl-everywhere-all members \"(^6500[0-247]:0)|(64499:6500[0-247])$\""

echo "\
delete policy-options community cl-as6886-own-prefixes
delete policy-options community cl-as6886-dn-prefixes
delete policy-options community cl-as6886-ua-prefixes
set policy-options community cl-as6886-own-prefixes members \"^6886:6886$\"
set policy-options community cl-as6886-dn-prefixes members \"^6886:65000$\"
set policy-options community cl-as6886-ua-prefixes members \"^6886:65100$\""
