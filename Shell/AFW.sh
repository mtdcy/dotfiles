#!/bin/bash 
# a pretty iptables script (c) Chen Fang 2023, mtdcy.chen@gmail.com.

set -e

#WAN=ens161          
LAN=br0             # lan interface 
N2N=n2n0
NET=10.10.10.0/24   # local net cidr
LIP=10.10.10.2      # LAN ip
NIP=10.20.30.2      # N2N ip
#WIP=172.31.1.2      # WAN ip

ALWAYS_LOG=1        # Otherwise log 5/min

# constants
TRACKED="-m conntrack --ctstate RELATED,ESTABLISHED"
LOCAL="-m addrtype --dst-type LOCAL"
BRIDGED="-m physdev --physdev-is-bridged"

TCPSYN="-p tcp --tcp-flags SYN,RST SYN"
TCPMSS="TCPMSS --set-mss 1300"

# IPtable Filter Target 
IPFT="-t nat"
# => Filter @ PREROUTING => best for a LAN firewall/DMZ host

# Syntax:
#   s - source 
#   d - destination
#   p - protocol 
#   m - match 
#   j - jump 
#   t - target
#   l - label

ipt="iptables"
# IPTable
# IPTtmj target "match" <ACCEPT|DROP|...> [comments]
IPTtmj() {
    #echo IPTtmj "$@"
    local rule="$1 $2 -j $3 -m comment --comment \"${@:4}\""

    # TARGET embbed in 'match'
    [ -z "$3" ] && rule="$1 $2 -m comment --comment \"${@:4}\""

    echo "$ipt -A $rule"
    #eval "$ipt -C $rule || $ipt -A $rule"
    eval "$ipt -A $rule"
}

# IPTp2m tcp|udp[:dports] [sports] => match
#  tcp,udp:53:80 => tcp:53:80 + udp:53:80
IPTp2m() {
    IFS=':' read proto ports <<< "$1"

    for p in ${proto//,/ }; do 
        #[ "$p" = "all" ] && echo "" && continue

        local match="-p $p"
        case "$ports" in 
            "")         ;;
            *:*|*,*)    match="$match -m multiport --dports $ports" ;;
            *)          match="$match -m $p --dport $ports"         ;;
        esac
        echo "$match"
    done
}

# IPTs2m source[:sport] => match
IPTs2m() {
    IFS=':' read source sport <<< "$1"
    local match
    case "$source" in
        any|"*")    ;;
        *.*.*.*)    match="-s $source" ;;
        *)          match="-i $source" ;;
    esac

    [ -z "$sport" ] || match="$match -m multiport --sports $sport" 
    echo "$match"
}

# IPTd2m destination[:dport] => match
IPTd2m() {
    IFS=':' read dest dport <<< "$1"
    local match
    case "$dest" in
        any|"*")    ;;
        *.*.*.*)    match="-d $dest" ;;
        *)          match="-o $dest" ;;
    esac

    [ -z "$dport" ] || match="$match -m multiport --dports $dport" 
    echo "$match"
}

# NEW_TARGET [table] target ["rule1" "rule2" "..."]
NEW_TARGET() {
    local table=""
    case "$1" in
        nat|mangle|raw) table="-t $1"; shift ;;
        "")             shift ;;
    esac

    local target="$1"
    echo "$ipt $table -N $target"
    $ipt $table -N $target 2> /dev/null || $ipt $table -F $target

    for rule in "${@:2}"; do
        local cmd
        case "$rule" in 
            LOG*) 
                IFS=' ' read _ prefix <<< "$rule"
                cmd="$ipt $table -A $target -j LOG --log-prefix \"$prefix => \""
                ;;
            *-j*)
                cmd="$ipt $table -A $target $rule"
                ;;
            *)
                cmd="$ipt $table -A $target -j $rule"
                ;;
        esac
        echo "$cmd"
        eval "$cmd"
    done
}

# ADD_TARGET [table] chain jump-to-new-TARGET ["sub rule" "..."]
#  => ADD_TARGET nat PREROUTING "-i br0" FIREWALL "prefix" RETURN
#   => iptables -t nat -N FIREWALL
#   => iptables -t nat -A FIREWALL -j LOG --log-prefix "$prefix"
#   => iptables -t nat -A PREROUTING -m "$match" -j FIREWALL
ADD_TARGET() {
    local table=""
    case "$1" in 
        nat|mangle|raw) table="$1"; shift ;;
    esac
    NEW_TARGET "$table" "$2" "${@:3}"

    [ -z "$table" ] || table="-t $table"

    local rule="$1 -j $2"
    echo "$ipt $table -A $rule"
    $ipt $table -C $rule 2> /dev/null || $ipt $table -A $rule
    # => we prefer to insert instead of append, but which is not compatible with docker
}

# ==============================================================================
# =============================== IPtable Filter ===============================
# IPFsmj source "match" TARGET [comments]
IPFsmj() {
    # Filter input @ INPUT or PREROUTING ?
    case "$3" in
        DNAT*)          IPTtmj "AFW-IPF -t nat" "$2 $(IPTs2m $1)" "$3" "${@:4}";;
        *)              IPTtmj "AFW-IPF $IPFT"  "$2 $(IPTs2m $1)" "$3" "${@:4}";;
    esac
}

# IPFdmj destination "match" TARGET [comments]
IPFdmj() {
    #echo IPFdmj "$@"
    case "$3" in
        MASQ*|SNAT*)    IPTtmj "AFW-NAT -t nat" "$2 $(IPTd2m $1)" "$3" "${@:4}";;
        *)              IPTtmj "AFW-NAT"        "$2 $(IPTd2m $1)" "$3" "${@:4}";;
    esac
}

# IPFspmj source tcp|udp[:dports] "match" TARGET [comments]
IPFspmj() {
    while read match; do
        IPFsmj "$1" "$match $3" "$4" "${@:5}"
    done <<< $(IPTp2m "$2")
}

# ==============================================================================
# BLOCK source tcp|udp[:dports] "match" [comments]
BLOCK() {
    IPFspmj "$1" "$2" "$3" LOG-DROP "${@:4}"
}

# ALLOW source tcp|udp[:dports] "match" [comments]
ALLOW() {
    case "$3" in
        *-j*)   IPFspmj "$1" "$2" "$3" ""     "${@:4}";;
        *)      IPFspmj "$1" "$2" "$3" ACCEPT "${@:4}";;
    esac
}

# DNAT source tcp|udp:dports destination|TARGET [comments]
DNAT() {
    case "$3" in
        *.*.*.*)    IPFspmj "$1" "$2" "$LOCAL" "DNAT --to $3" "${@:4}" ;;
        *)          IPFspmj "$1" "$2" "$LOCAL" "$3"           "${@:4}" ;;
    esac
}

# FORWARD destination source "match" TARGET [comments]
FORWARD() {
    IPFdmj "$1" "$(IPTs2m $2) $3" "$4" "${@:5}"
}

# SNAT destination source "match" to|TARGET [comments]
SNAT() {
    case "$4" in
        *.*.*.*)    IPFdmj "$1" "$(IPTs2m $2) $3" "SNAT --to $4" "${@:5}" ;;
        *)          IPFdmj "$1" "$(IPTs2m $2) $3" "$4"           "${@:5}" ;;
    esac
}

# NAT1 destination source "match" to|TARGET [comments]
NAT1() {
    # FUCK:
    #  = at least two conditions must be here for each FORWARD command 
    #   => spent two days stuck here
    #    => e.g: FORWARD br0 any "" ACCEPT won't work 
    FORWARD "$1" "$2" "$3"          ACCEPT  "${@:5}"
    FORWARD "$2" "$1" "$TRACKED"    ACCEPT  "${@:5}"


    local TARGET="$4"
    case "$TARGET" in 
        *.*.*.*)    TARGET="SNAT --to $TARGET" ;; 
    esac

    if [[ $TARGET =~ ^MASQ* ]] || [[ $TARGET =~ ^SNAT* ]]; then
        case "$2" in
            *.*.*.*)    SNAT "$1" "$2" "$3" "$4" "${@:5}" ;;
            *)          SNAT "$1" any  "$3" "$4" "${@:5}" ;; # no match input devices
        esac
    fi
}

# ==============================================================================
# IPtable Logger 
# IPLtml target tcp|udp[:dports] "match" "label"
IPLtpm() {
    while read match; do
        IPTtmj "$1" "$match $3" "LOG --log-prefix \"$4: \"" "$4"
    done <<< $(IPTp2m "$2")
}

# IPLOG source destination tcp|udp[:dports] "match" [label]
IPLOG() {
    local match="$(IPTs2m $1) $(IPTd2m $2)"
    case "$1" in
        *.*.*.*)    pos="$match"        ;;
        *)          pos="$(IPTd2m $2)"  ;; # no input device for OUTPUT/POSTROUTING 
    esac

    case "$2" in
        *.*.*.*)    inp="$match"        ;;
        *)          inp="$(IPTs2m $1)"  ;; # no output device for PREROUTING/INPUT
    esac

    IPLtpm  "AFW-IPF $IPFT"     "$3" "$inp $4" "IPL:PRE:${@:5}"
    IPLtpm  "AFW-NAT"           "$3" "$fwd $4" "IPL:FWD:${@:5}"
    IPLtpm  "AFW-NAT -t nat"    "$3" "$pos $4" "IPL:POS:${@:5}"
}

# library mode
if [ $# -gt 0 ]; then 
    echo "$@"
    eval "$@"
    exit $?
fi

# ==============================================================================
# INITIAL: 
#  => NEVER FLUSH preset chains

ADD_TARGET      INPUT               AFW-IPF
ADD_TARGET nat  PREROUTING          AFW-IPF
ADD_TARGET      FORWARD             AFW-NAT
ADD_TARGET nat  POSTROUTING         AFW-NAT

# Blocked Packets: LOG -> DROP
NEW_TARGET      LOG-DROP            "LOG INP:DROP"  DROP
NEW_TARGET nat  LOG-DROP            "LOG PRE:DROP"  "DNAT --to 0.0.0.1"   # => Black Hole
# => DROP not allowed in nat/PREROUTING, so throw it into a black hole

# Abort Forwarding: LOG -> DROP
NEW_TARGET      LOG-ABRT            "LOG NAT:DROP"  DROP

# SNAT CHAIN
NEW_TARGET nat  SNAT-LAN            "SNAT --to $LIP"
#NEW_TARGET nat  SNAT-WAN            MASQUERADE
#NEW_TARGET nat  SNAT-WAN            "SNAT --to $WIP"
NEW_TARGET nat  SNAT-N2N            "SNAT --to $NIP"

# ==============================================================================

# ==============================================================================
# ==================================== IPLOG ===================================
IPLOG   10.10.10.102    any             tcp:9922    ""                  "XXX"
IPLOG   10.10.10.102    10.10.10.200    tcp:22      ""                  "XXX"

# ==============================================================================
# =================================== DNAT =====================================
#       #source         #tcp,udp[:dports]           #destination        #comments 

#DNAT    any             tcp:5000,5001               10.10.10.200        "NAS/DSM"  # Use nginx
DNAT    any             tcp:548,139,445             10.10.10.200        "NAS/SMB"   # AFP/SMB
DNAT    any             tcp:6690                    10.10.10.200        "NAS/DRIVE" # Synology Drive

# SSH 
DNAT    any             tcp:6015                    10.10.10.2:22       "SSH/DMZ"   # ues the same port as ECS
DNAT    any             tcp:9922                    10.10.10.200:22     "SSH/NAS"   # for rsync 

DNAT    any             tcp:3389                    10.10.10.202        "WIN/RDP"

# docker compatible
DNAT    any             all                         DOCKER              "DOCKER"
# => always after our DNAT rules, and before our Allow/Block rules

# ==============================================================================

# ==============================================================================
# ================================= Allow/Block ================================
#A/B    #source         #tcp|udp[:dports]           #match              #comments

ALLOW   lo              all                         ""                  "ALLOW/lo"
ALLOW   any             all                         "$TRACKED"          "ALLOW/Tracked" # Allow Tracked Connections 
#ALLOW   $N2N            all                         ""                  "ALLOW/N2N"     # Allow All @ N2N
ALLOW   $NET            all                         ""                  "ALLOW/Local"   # Allow All Local Traffics

ALLOW   any             icmp                        ""                  "ALLOW/ICMP"
ALLOW   any             igmp                        ""                  "ALLOW/IGMP"
ALLOW   $NET            tcp:22                      ""                  "ALLOW/ssh"     # Local Only
ALLOW   any             udp:53                      ""                  "ALLOW/DNS"
ALLOW   any             udp:67,68                   ""                  "ALLOW/DHCP"
ALLOW   any             tcp:80,8880                 ""                  "ALLOW/http"    # 8880 => custom http port 
ALLOW   any             tcp:443,8443                ""                  "ALLOW/https"   # 8443 => custom https port
ALLOW   any             tcp:5000,5001               ""                  "ALLOW/DSM"     # NAS/DSM
ALLOW   any             tcp:123                     ""                  "ALLOW/NTP"
#ALLOW   $NET            udp:1900                    ""                  "ALLOW/UPnP"
ALLOW   any             tcp:3389                    ""                  "ALLOW/RDP"
ALLOW   any             tcp:5201                    ""                  "ALLOW/iperf3"
ALLOW   $NET            tcp,udp:7070                ""                  "ALLOW/Socks5"
ALLOW   any             tcp,udp:6677                ""                  "ALLOW/N2N"

BLOCK   any             all                         ""                  "BLOCK/ALL"     # FINAL: Block All
# ==============================================================================

# ==============================================================================
# ==================================== NAT =====================================
#NAT    #dest           #source         #match      #TARGET             #comments

FORWARD 0.0.0.1         any             ""          DROP                "Black Hole"

FORWARD $LAN             any            "$BRIDGED"  ACCEPT              "BRIDGED"

# DOCKER compatible 
FORWARD docker0         any             ""          RETURN              "DOCKER"
FORWARD any             docker0         ""          RETURN              "DOCKER"

#NAT1    $WAN            any             ""          SNAT-WAN            "NAT/WAN"       # ? -> WAN

# => we want to keep source address info, so ACCEPT traffics to Local NET without SNAT 
#  => this is why we want to Allow/Block @ PREROUTING 
#   => DNAT works without SNAT
FORWARD $LAN            any             ""          ACCEPT              "NAT/LAN" 
FORWARD any             $LAN            ""          ACCEPT              "NAT/LAN"
SNAT    $LAN            any             "! -d $NET" SNAT-LAN            "NAT/LAN"       # outgoing 
SNAT    $LAN            $NET            "-d $NET"   SNAT-LAN            "NAT/Local"     # Local NET SNAT

FORWARD $N2N            any             "$TCPSYN"   "$TCPMSS"           "N2N/TCPMSS"
NAT1    $N2N            any             ""          SNAT-N2N            "NAT/N2N"       # LAN -> N2N

FORWARD any             any             ""          LOG-ABRT            "NAT/END"       # FINAL: Abort Forwarding 
# ==============================================================================

$ipt -nvL
$ipt -t nat -nvL
