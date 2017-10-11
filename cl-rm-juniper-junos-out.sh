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
delete policy-options community cl-${1}-${nei_t}$suff-$i
set policy-options community cl-${1}-${nei_t}$suff-$i members \"^65${4}${2}${i}:${3}$\"";
        done
    fi
    for i in 0 1 2 4 7 9; do	#cl-<name>-<peergroup>-<suff>-<action>
        echo "\
delete policy-options community cl-${1}-${nei_t}-$i
set policy-options community cl-${1}-${nei_t}-$i members \"^650${2}${i}:${3}$\"";
    done
    for i in 0 1 2 4 7 9; do   #dependence from cl-${1}-everywhere for every peer group
        echo "\
delete policy-options community cl-${1}-everywhere-$i
set policy-options community cl-${1}-everywhere-$i members \"^6500${i}:${3}$\""; 
    done
    # Term number in junos is only label, we need to sort route-map terms before output
    # store STDOUT in 4, redirect it to file and restore before cat file to it.
    t=/tmp/cl-rm`date +%s`.tmp
    exec 4<&1
    exec 1>${t}
    echo "\
delete policy-options policy-statement rm-${1}-${nei_t}$suff-out"
    if [ -n "${4}" ]; then
        echo "\
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 5 then reject
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 5 from community cl-${1}-${nei_t}$suff-9
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 5 then community delete cl-4-delete-on-out"
    fi
    echo "\
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 75 then reject
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 75 from community cl-${1}-${nei_t}-9
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 75 then community delete cl-4-delete-on-out
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${2}05 then reject
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${2}05 from community cl-${nei_t}-9
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${2}05 then community delete cl-4-delete-on-out
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 805 then reject
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 805 from community cl-${1}-everywhere-9
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 805 then community delete cl-4-delete-on-out
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 905 then reject
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 905 from community cl-everywhere-9
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 905 then community delete cl-4-delete-on-out"
    for i in 7 4 2 1; do
        prepend=''
        k=$i
        n=$(expr 8 - \( ${i} \))
        while [ ${k} -gt 0 ]; do prepend="64499 ${prepend}"; k=$(expr \( $k \) - 1); done
        if [ -n "${4}" ]; then
            echo "\
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${4}${n} then accept
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${4}${n} from community cl-${1}-${nei_t}$suff-${i}
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${4}${n} then as-path-prepend \"${prepend}\"
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${4}${n} then community delete cl-4-delete-on-out"
        fi
        echo "\
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 8${n} then accept
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 8${n} from community cl-${1}-${nei_t}-$i
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 8${n} then as-path-prepend \"${prepend}\"
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 8${n} then community delete cl-4-delete-on-out
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${2}${n}0 then accept
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${2}${n}0 from community cl-${nei_t}-$i
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${2}${n}0 then as-path-prepend \"${prepend}\"
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${2}${n}0 then community delete cl-4-delete-on-out
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 8${n}0 then accept
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 8${n}0 from community cl-${1}-everywhere-$i
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 8${n}0 then as-path-prepend \"${prepend}\"
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 8${n}0 then community delete cl-4-delete-on-out
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 9${n}0 then accept
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 9${n}0 from community cl-everywhere-$i
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 9${n}0 then as-path-prepend \"${prepend}\"
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 9${n}0 then community delete cl-4-delete-on-out"
    done
    if [ -n "${4}" ]; then
        echo "\
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${4}9 then accept
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${4}9 from community cl-${1}-${nei_t}$suff-0
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${4}9 then community delete cl-4-delete-on-out"
    fi
    echo "\
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 95 then accept
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 95 from community cl-${1}-${nei_t}-0
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 95 then community delete cl-4-delete-on-out
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${2}95 then accept
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${2}95 from community cl-${nei_t}-0
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term ${2}95 then community delete cl-4-delete-on-out
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 895 then accept
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 895 from community cl-${1}-everywhere-0
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 895 then community delete cl-4-delete-on-out
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 995 then accept
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 995 from community cl-everywhere-0
set policy-options policy-statement rm-${1}-${nei_t}$suff-out term 995 then community delete cl-4-delete-on-out"
    exec 1<&4
    cat ${t}|sort -k6 -n
    rm ${t}
    echo "\
set policy-options policy-statement rm-${1}-${nei_t}$suff-out then reject"
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

