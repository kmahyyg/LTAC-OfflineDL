#!/bin/bash

check_env(){
    if [[ -z ${EDITOR} ]]; then
        echo "Please set EDITOR envvar."
        exit 1
    fi

    if [[ ${EUID} -eq "0" ]]; then
        echo "DO NOT RUN AS PRIVILEGED USER!"
        exit 1
    fi

    CURLLOC=$(which curl)
    if [ "$?" -eq 1 ]; then
        echo "CURL not found!"
        exit 1
    fi
}

get_tracker(){
    curl -sSL -O https://ngosang.github.io/trackerslist/trackers_all.txt
    if [[ "$?" -eq 0 ]]; then
        sed ':a;N;$!ba;s/\n\n/,/g'  trackers_all.txt > /tmp/trackers.aria2 
        ALLTRACKERS=$(cat /tmp/trackers.aria2)
        rm /tmp/trackers.aria2
    else
        echo "Failed to get trackers list."
        exit 1
    fi
}

init_cfg(){
    mkdir -p ~/.aria2
    cat <<EOF > ~/.aria2/aria2.conf
dir=${HOME}/aria2dwd
disk-cache=32M
file-allocation=trunc
continue=true
max-concurrent-downloads=5
max-connection-per-server=16
min-split-size=10M
split=20

#max-overall-download-limit=0
#max-download-limit=0
#max-overall-upload-limit=1M
#max-upload-limit=1000

disable-ipv6=true

input-file=${HOME}/.aria2/aria2.session
save-session=${HOME}/.aria2/aria2.session
#save-session-interval=60

enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=true
event-poll=epoll
rpc-listen-port=6899
rpc-secret=$(python3 -c 'import secrets; print(secrets.token_hex(16))')
rpc-secure=true
rpc-certificate=
rpc-private-key=

follow-torrent=true
listen-port=15341
bt-max-peers=500
enable-dht=true
enable-dht6=false
#dht-listen-port=16881-16999
bt-enable-lpd=true
enable-peer-exchange=true
#bt-request-peer-speed-limit=50K

peer-id-prefix=-TR2770-
user-agent=Transmission/2.77

seed-ratio=1.5
#force-save=false
bt-hash-check-seed=true
bt-seed-unverified=true
#bt-save-metadata=true

bt-tracker=${ALLTRACKERS}
EOF
    echo "We will open editor for you to edit the aria2 config."
    echo "For more details, please check aria2c config."
    echo "You will need to fulfill those patterns yourself: "
    echo "    IF you use private tracker, you know what you need to do!"
    echo "        - Disable DHT, LPD, Peer Exchange"
    echo "    ALL of you must fulfill:"
    echo "        - rpc-certificate=<THE HTTPS CERT LOCATION>"
    echo "        - rpc-private-key=<THE HTTPS CERT PRIVATE KEY LOCATION>"
    echo "Since the data transport need to be HTTPS, you need to use certificate."
    echo ""
    sleep 6
    ${EDITOR} ~/.aria2/aria2.conf
}

main(){
    check_env
    get_tracker
    init_cfg
}

main
