#!/bin/sh
./optimus.sh|grep '^ip community-list standard' | awk '{print $6}'| sort -n | uniq | perl -ne 's/^(.*?)((65)(\d)(\d)(\d)(:(\d+))*)|(.*)$/if ($5!=9) {print "$1$3$4$5$6$7$9,ingress,announce to peer group $5 with $6 prepend"} else {print "$1$3$4$5$6$7$9,ingress,not announce to peer group $5"}; if ($8!=0) {print " (AS$8"; if ($4!=0) {print " peer $4"}; print ")"}/e;print "\n"'
