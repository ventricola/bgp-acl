# bgp-acl
    ------------------------------------------------------------------------------------------
    ingress communities - announce labels for prefixes
    ------------------------------------------------------------------------------------------
    650ZX:0, 64499:650ZX - announce to Z peer group with X=0,1,2,4,7 prepend, X=9 - not announce
    65KZX:YYY - announce to ASYYY with X=0,1,2,4,7 prepend, X=9 - not announce
    Z is 0 for everywhere, 1 - uplink (inet), 2 - ix, 3 - peer, 4 - customer, 5 - iBGP
    X=0,1,2,4,7 prepend, X=9 - not announce
    K is 0 to 3 (in the certain peer group where Z is 1 to 4) where 0 - to every peer from ASYYY, 1 accordingly - to the 1st, 2 - to the 2nd, 3 to the 3rd peer
    
    
    ------------------------------------------------------------------------------------------
    ingress communities (0) - announce everywhere
    ------------------------------------------------------------------------------------------
    65000:0, 64499:65000 - announce everywhere.
    65009:0, 64499:65009 - not announce everywhere.
    6500X:0, 64499:6500X - announce everywhere with X=0,1,2,4,7 prepend, X=9 - not announce
    65K0X:YYY - announce to ASYYY with X=0,1,2,4,7 prepend, X=9 - not announce
    K is 0 to 3 where 0 - to every peer from ASYYY, 1 accordingly - to the 1st, 2 - to the 2nd, 3 to the 3rd peer
    ------------------------------------------------------------------------------------------
    ingress communities (1) - announce to AS64499 uplinks
    ------------------------------------------------------------------------------------------
    65010:0, 64499:65010 - announce to all uplinks.
    65019:0, 64499:65019 - not announce to all uplinks.
    6501X:0, 64499:6501X - announce to all uplinks with X=0,1,2,4,7 prepend, X=9 - not announce
    65K1X:YYY - announce to ASYYY uplinks with X=0,1,2,4,7 prepend, X=9 - not announce
    K is 0 to 3 where 0 - to every peer from ASYYY, 1 accordingly - to the 1st, 2 - to the 2nd, 3 to the 3rd peer
    ------------------------------------------------------------------------------------------
    ingress communities (2) - announce to AS64499 ixes (public peers)
    ------------------------------------------------------------------------------------------
    65020:0, 64499:65020 - announce to all ixes.
    65029:0, 64499:65029 - not announce to all ixes.
    6502X:0, 64499:6502X - announce to all ixes with X=0,1,2,4,7 prepend, X=9 - not announce
    65K2X:YYY - announce to ixes ASYYY with X=0,1,2,4,7 prepend, X=9 - not announce
    K is 0 to 3 where 0 - to every peer from ASYYY, 1 accordingly - to the 1st, 2 - to the 2nd, 3 to the 3rd peer
    ------------------------------------------------------------------------------------------
    ingress communities (3) - announce to AS64499 peers (private peers)
    ------------------------------------------------------------------------------------------
    65030:0, 64499:65030 - announce to all peers.
    65039:0, 64499:65039 - not announce to all peers.
    6503X:0, 64499:6503X - announce to all peers with X=0,1,2,4,7 prepend, X=9 - not announce
    65K3X:YYY - announce to ASYYY peer with X=0,1,2,4,7 prepend, X=9 - not announce
    K is 0 to 3 where 0 - to every peer from ASYYY, 1 accordingly - to the 1st, 2 - to the 2nd, 3 to the 3rd peer
    ------------------------------------------------------------------------------------------
    ingress communities (4) - announce to AS64499 customers
    ------------------------------------------------------------------------------------------
    65040:0, 64499:65040 - announce to all customers.
    65049:0, 64499:65049 - not announce to all customers.
    6504X:0, 64499:6504X - announce to all customers with X=0,1,2,4,7 prepend, X=9 - not announce
    65K4X:YYY - announce to ASYYY customers with X=0,1,2,4,7 prepend, X=9 - not announce
    K is 0 to 3 where 0 - to every peer from ASYYY, 1 accordingly - to the 1st, 2 - to the 2nd, 3 to the 3rd peer
    ------------------------------------------------------------------------------------------
    ingress communities (5) - announce to AS64499 itself (not implemented and may be not in future! needs more consideration)
    ------------------------------------------------------------------------------------------
    65050:0, 64499:65050 - accept announce.
    65059:0, 64499:65059 - not accept announce.
    6505X:0, 64499:6505X - accept announce with X=0,1,2,4,7 prepend, X=9 - not accept
    
    ------------------------------------------------------------------------------------------
    egress communities - announces from
    ------------------------------------------------------------------------------------------
    #64496-64511 Reserved for use in documentation and sample code [RFC5398]
    #64512-65534 Reserved for Private Use [RFC6996]
    #65535 Reserved [RFC7300]
    #0 and 1 are also unused, for 32-bit AS I suppose to add 2 communities like 0:LOW and 1:HI LOW for low 16 bit and HI accordinlu
    #and 23456 in YYY notations i.e. for AS196638 we need 3 communities for 64499:196638 - 64499:23456, 0:30, 1:3, thats ugly but may work.
    
    64499:0 - default route
    64499:64499 - AS64499
    64499:YYY - ASYYY
    
    64499:64MZN - route M type from Z group with N factor
    64MZN:YYY - route M type from Z group with N factor from ASYYY (0 equal to 64499:64MZN)
    M is [5-9] 9 - from peer group, 8 - from location #M must be >= 5.
    Z is [0-9] for 64499:649ZN. 0 from everywhere, 1 - uplink (inet), 2 - ix, 3 - peer, 4 - customer, 5 - AS64499.
               for 64499:648ZN. 0 from everywhere, 1 - inet (world), 2 - Ukraine, 3 - Russia, 4 - Donetsk.
    N is [0-9] 0 for whatever
    
    ------------------------------------------------------------------------------------------
    local preference
    ------------------------------------------------------------------------------------------
    64499:10500      Set localpref to 500 (pref 65035) (highest possible)
    
    64499:10475      Set localpref to 475 (pref 65060) (highest customer)
    64499:10450      Set localpref to 450 (pref 65085) (customer)
    64499:10425      Set localpref to 425 (pref 65110) (lower customer)
    64499:10400      Set localpref to 400 (pref 65135) (backup customer)
    
    64499:10375      Set localpref to 375 (higest private peering)
    64499:10350      Set localpref to 350 (preferred private peering)
    64499:10325      Set localpref to 325 (lower private peering)
    64499:10300      Set localpref to 300 (backup private peering)
    
    64499:10275      Set localpref to 275 (highest public peering)
    64499:10250      Set localpref to 250 (preferred public peering)
    64499:10225      Set localpref to 225 (lower public peering)
    64499:10200      Set localpref to 200 (backup public peering)
    
    64499:10175      Set localpref to 175 (highest primary uplink)
    64499:10150      Set localpref to 150 (pref 65385) (primary uplink)
    64499:10125      Set localpref to 125 (lower primary uplink)
    64499:10100      Set localpref to 100 (backup uplink)
    
    64499:10050      Set localpref to 50  (minimal, full backup)
