#!/bin/sh

community() { #$1 - community-list name, $2 - 0,1,2,3,4 (everywhere to customers), $3 - aut-num[, $4 - peer sequence index in group]
    case ${2} in
        0) nei_t='everywhere' ;;
        1) nei_t='uplink' ;;
        2) nei_t='ix' ;;
        3) nei_t='peer' ;;
        4) nei_t='customer' ;;
        *) exit 255 ;;
    esac
    if [ -n "${4}" ]; then
        suff="-${4}"
        for i in 0 1 2 4 7 9; do	#cl-<name>-<peergroup>-<suff>-<action>
            echo "\
no ip community-list standard cl-${1}-${nei_t}$suff-$i
ip community-list standard cl-${1}-${nei_t}$suff-$i permit 65${4}${2}${i}:${3}";
        done
    fi
    for i in 0 1 2 4 7 9; do	#cl-<name>-<peergroup>-<action>
        echo "\
no ip community-list standard cl-${1}-${nei_t}-$i
ip community-list standard cl-${1}-${nei_t}-$i permit 650${2}${i}:${3}";
    done
    for i in 0 1 2 4 7 9; do	#dependence from cl-${1}-everywhere for every peer group
        echo "\
no ip community-list standard cl-${1}-everywhere-$i
ip community-list standard cl-${1}-everywhere-$i permit 6500${i}:${3}"; 
    done
    echo "\
no route-map rm-${1}-${nei_t}$suff-out"
    if [ -n "${4}" ]; then
        echo "\
route-map rm-${1}-${nei_t}$suff-out deny 5
 match community cl-${1}-${nei_t}$suff-9
 set comm-list cl-4-delete-on-out delete"
    fi
    echo "\
route-map rm-${1}-${nei_t}$suff-out deny 75
 match community cl-${1}-${nei_t}-9
 set comm-list cl-4-delete-on-out delete
route-map rm-${1}-${nei_t}$suff-out deny ${2}05
 match community cl-${nei_t}-9
 set comm-list cl-4-delete-on-out delete
route-map rm-${1}-${nei_t}$suff-out deny 805
 match community cl-${1}-everywhere-9
 set comm-list cl-4-delete-on-out delete
route-map rm-${1}-${nei_t}$suff-out deny 905
 match community cl-everywhere-9
 set comm-list cl-4-delete-on-out delete"
    for i in 7 4 2 1; do
        prepend=''
        k=$i
        n=$(expr 8 - \( ${i} \))
        while [ ${k} -gt 0 ]; do prepend="64499 ${prepend}"; k=$(expr \( $k \) - 1); done
        if [ -n "${4}" ]; then
            echo "\
route-map rm-${1}-${nei_t}$suff-out permit ${4}${n}
 match community cl-${1}-${nei_t}$suff-$i
 set as-path prepend ${prepend}
 set comm-list cl-4-delete-on-out delete"
        fi
        echo "\
route-map rm-${1}-${nei_t}$suff-out permit 8${n}
 match community cl-${1}-${nei_t}-$i
 set as-path prepend ${prepend}
 set comm-list cl-4-delete-on-out delete
route-map rm-${1}-${nei_t}$suff-out permit ${2}${n}0
 match community cl-${nei_t}-$i
 set as-path prepend ${prepend}
 set comm-list cl-4-delete-on-out delete
route-map rm-${1}-${nei_t}$suff-out permit 8${n}0
 match community cl-${1}-everywhere-$i
 set as-path prepend ${prepend}
 set comm-list cl-4-delete-on-out delete
route-map rm-${1}-${nei_t}$suff-out permit 9${n}0
 match community cl-everywhere-$i
 set as-path prepend ${prepend}
 set comm-list cl-4-delete-on-out delete"
    done
    if [ -n "${4}" ]; then
        echo "\
route-map rm-${1}-${nei_t}$suff-out permit ${4}9
 match community cl-${1}-${nei_t}$suff-0
 set comm-list cl-4-delete-on-out delete"
    fi
    echo "\
route-map rm-${1}-${nei_t}$suff-out permit 95
 match community cl-${1}-${nei_t}-0
 set comm-list cl-4-delete-on-out delete
route-map rm-${1}-${nei_t}$suff-out permit ${2}95
 match community cl-${nei_t}-0
 set comm-list cl-4-delete-on-out delete
route-map rm-${1}-${nei_t}$suff-out permit 895
 match community cl-${1}-everywhere-0
 set comm-list cl-4-delete-on-out delete
route-map rm-${1}-${nei_t}$suff-out permit 995
 match community cl-everywhere-0
 set comm-list cl-4-delete-on-out delete
exit"
}

help() {
        echo; echo "Create route-maps and community-lists for BGP router named in $0."
        echo; echo "${0} <label> <neighbor-type-number> <aut-num> [<peers amount>]"
        echo "Pick neighbor type number from the following table:
        0 - everywhere
        1 - uplink
        2 - ix
        3 - peer
        4 - customer

        0 < <peers amount> <= 6.
"
}
if [ -z "${1}" -o -z "${2}" -o -z "${3}" ]; then
        help
        exit 1
fi

if [ -n "${4}" ]; then
    if [ ! \( "${4}" -gt 0 -a "${4}" -le 6 \) ]; then
        help
        exit 1
    fi
    for k in `seq 1 ${4}`; do community ${1} ${2} ${3} ${k}; done
else
    community ${1} ${2} ${3}
fi

