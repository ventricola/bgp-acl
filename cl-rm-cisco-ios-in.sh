#!/bin/sh

rm_in() { #$1 - peer name, $2 - 0,1,2,3,4 (everywhere to customers), $3 0,1,2,3,4 (everywhere to Donetsk), $4 - aut-num, $5 - prefix-list, $6 - as-path list, 
    case ${2} in
        0) nei_t='anypeer'; nei_lp='50' ;;
        1) nei_t='uplink'; nei_lp='150' ;;
        2) nei_t='ix'; nei_lp='250' ;;
        3) nei_t='peer'; nei_lp='350' ;;
        4) nei_t='customer'; nei_lp='450' ;;
        *) exit 255 ;;
    esac
    case ${3} in
        0) loc_t='anyloc' ;;
        1) loc_t='world' ;;
        2) loc_t='ua' ;;
        3) loc_t='ru' ;;
        4) loc_t='dn' ;;
        *) exit 255 ;;
    esac

    echo "\
no route-map rm-${1}-${nei_t}-in
route-map rm-${1}-${nei_t}-in permit 5
 match ip address prefix-list ${5}
 match as-path ${6}
 set local-preference ${nei_lp}
 set community 65040:0 65050:0 64499:${4} 64499:64900 64499:64800 64499:649${2}0 64499:648${3}0 64900:${4} 64800:${4} 649${2}0:${4} 648${3}0:${4}
route-map rm-${1}-${nei_t}-in deny 100
exit
no ip community-list standard cl-from-as${4}
ip community-list standard cl-from-as${4} permit 64499:${4}
no ip community-list standard cl-from-as${4}-anypeer
ip community-list standard cl-from-as${4}-anypeer permit 64900:${4}
no ip community-list standard cl-from-as${4}-anyloc
ip community-list standard cl-from-as${4}-anyloc permit 64800:${4}
no ip community-list standard cl-from-as${4}-${nei_t}
ip community-list standard cl-from-as${4}-${nei_t} permit 649${2}0:${4}
no ip community-list standard cl-from-as${4}-${loc_t}
ip community-list standard cl-from-as${4}-${loc_t} permit 648${2}0:${4}"
}

help() {
        echo; echo "Create route-maps and community-lists for BGP router named in $0."
        echo; echo "${0} label neighbor-type-number neighbor-location aut-num prefix-list as-path-acl"
        echo "Pick neighbor type number from the following table:
        0 - everywhere
        1 - uplink
        2 - ix
        3 - peer
        4 - customer
        5 - dec"
        echo "Pick neighbor location number from the following table:
        0 - everywhere
        1 - world
        2 - Ukraine
        3 - Russia
        4 - Donetsk"
}
if [ -z "${1}" -o -z "${2}" -o -z "${3}" -o -z "${4}" -o -z "${5}" -o -z "${6}" ]; then
        help
        exit 1
fi

rm_in ${1} ${2} ${3} ${4} ${5} ${6}
