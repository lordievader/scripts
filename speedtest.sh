#!/bin/bash
### HTTP based
# wget -4 --output-document=/dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip
# wget -4 -O /dev/null 'http://ftp.snt.utwente.nl/pub/test/100000M'

### SSH based
# pv -tpreb /dev/zero|ssh root@corellian dd of=/dev/null
#pv -tpreb /dev/zero|ssh -i ~/.ssh/masterkey root@10.0.2.1 dd of=/dev/null

# src: https://stackoverflow.com/a/29754866
# saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset

! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo "I’m sorry, `getopt --test` failed in this environment."
    exit 1
fi

function test_http () {
    SNT=$1
    SOFTLAYER=$2
    size=$3
    if [[ $SNT == 1 ]]; then
        wget --output-document=/dev/null "http://ftp.snt.utwente.nl/pub/test/${size}M"
    elif [[ $SOFTLAYER == 1 ]]; then
        wget --output-document=/dev/null "http://speedtest.wdc01.softlayer.com/downloads/test${size}.zip"
    else
        wget --output-document=/dev/null "http://ftp.snt.utwente.nl/pub/test/${size}M"
    fi
}

function test_ssh () {
    CORELLIAN=$1
    SLAVE=$2
    size=$3
    if [[ $CORELLIAN == 1 ]]; then
        ssh -i ~/.ssh/masterkey corellian pv -s ${size}M -S /dev/zero|pv -tpreb -s ${size}M >/dev/null
    elif [[ $SLAVE == 1 ]]; then
        ssh -i ~/.ssh/masterkey 10.0.2.1 pv -s ${size}M -S /dev/zero|pv -tpreb -s ${size}M >/dev/null
    else
        ssh -i ~/.ssh/masterkey corellian pv -s ${size}M -S /dev/zero|pv -tpreb -s ${size}M >/dev/null
    fi
}

OPTIONS=hs
LONGOPTS=http,ssh,snt,softlayer,corellian,slave

# -use ! and PIPESTATUS to get exit code with errexit set
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

HTTP=0
SNT=0
SOFTLAYER=0
SSH=0
CORELLIAN=0
SLAVE=0
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -h|--http)
            HTTP=1
            shift
            ;;
        -s|--ssh)
            SSH=1
            shift
            ;;
        --snt)
            SNT=1
            shift
            ;;
        --softlayer)
            SOFTLAYER=1
            shift
            ;;
        --corellian)
            CORELLIAN=1
            shift
            ;;
        --slave)
            SLAVE=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

start=$(date +%s%N | cut -b1-13)
size=1000
if [[ $HTTP == 1 ]]; then
    test_http $SNT $SOFTLAYER $size
elif [[ $SSH == 1 ]]; then
    test_ssh $CORELLIAN $SLAVE $size
else
    printf "No test type specified.\n"
    exit 0
fi
end=$(date +%s%N | cut -b1-13)
echo -n "MBit/s: "
echo "$size $start $end"|awk '{print 8 * 1000 * $1 / ($3-$2)}'
