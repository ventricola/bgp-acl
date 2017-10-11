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
delete policy-options community cl-${1}-${nei_t}-in
set policy-options community cl-${1}-${nei_t}-in members \"65040:0\"
set policy-options community cl-${1}-${nei_t}-in members \"65050:0\"
set policy-options community cl-${1}-${nei_t}-in members \"64499:${4}\"
set policy-options community cl-${1}-${nei_t}-in members \"64499:64900\"
set policy-options community cl-${1}-${nei_t}-in members \"64499:64800\"
set policy-options community cl-${1}-${nei_t}-in members \"64499:649${2}0\"
set policy-options community cl-${1}-${nei_t}-in members \"64499:648${3}0\"
set policy-options community cl-${1}-${nei_t}-in members \"64900:${4}\"
set policy-options community cl-${1}-${nei_t}-in members \"64800:${4}\"
set policy-options community cl-${1}-${nei_t}-in members \"649${2}0:${4}\"
set policy-options community cl-${1}-${nei_t}-in members \"648${3}0:${4}\"
delete policy-options policy-statement rm-${1}-${nei_t}-in
set policy-options policy-statement rm-${1}-${nei_t}-in term 5 from prefix-list-filter ${5} orlonger
set policy-options policy-statement rm-${1}-${nei_t}-in term 5 from as-path-group ${6}
set policy-options policy-statement rm-${1}-${nei_t}-in term 5 then local-preference ${nei_lp}
set policy-options policy-statement rm-${1}-${nei_t}-in term 5 then community set cl-${1}-${nei_t}-in
set policy-options policy-statement rm-${1}-${nei_t}-in term 5 then accept
set policy-options policy-statement rm-${1}-${nei_t}-in then reject
delete policy-options community cl-from-as${4}
set policy-options community cl-from-as${4} members \"^64499:${4}$\"
delete policy-options community cl-from-as${4}-anypeer
set policy-options community cl-from-as${4}-anypeer members \"^64900:${4}$\"
delete policy-options community cl-from-as${4}-anyloc
set policy-options community cl-from-as${4}-anyloc members \"^64800:${4}$\"
delete policy-options community cl-from-as${4}-${nei_t}
set policy-options community cl-from-as${4}-${nei_t} members \"^649${2}0:${4}$\"
delete policy-options community cl-from-as${4}-${loc_t}
set policy-options community cl-from-as${4}-${loc_t} members \"^648${2}0:${4}$\""
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
