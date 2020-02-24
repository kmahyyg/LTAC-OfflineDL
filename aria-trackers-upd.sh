#!/bin/bash

FDPATH=$1
DOMAIN=$2
PT_ENABLED=$3

check_env(){
    if [[ -z ${FDPATH} || -z ${DOMAIN} ]]; then
        echo "PLEASE OFFER CERT FOLDER PATH AND DOMAIN NAME."
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

    if [ "${PT_ENABLED}" == "1" ]; then
        SETTINGS_DHT="false"
    else
        SETTINGS_DHT="true"
    fi

    mkdir -p "${HOME}"/.aria2
}

build_certpath(){
    echo "Do you use CDN to host WebUI? If you don't know what's this, say n. (y/n)"
    read -r CDN_ENABLED
    DOMAIN_ARIA="${DOMAIN}"
    case ${CDN_ENABLED} in 
        "y")
            echo "Please write the origin site domain name: (DO NOT USE CDN ONE!) "
            read -r DOMAIN_ARIA
	    if [[ ${#DOMAIN_ARIA} -le 3 ]]; then
                echo "NO INPUT, USE DEFAULT!"
                DOMAIN_ARIA="${DOMAIN}"
	    fi
            ;;
    esac
    CERTPATH="${FDPATH}/${DOMAIN_ARIA}/fullchain.cer"
    PRIVKEY="${FDPATH}/${DOMAIN_ARIA}/${DOMAIN_ARIA}.key"
    if [[ -f ${CERTPATH} && -f ${PRIVKEY} ]]; then
        echo ${CERTPATH}
        echo ${PRIVKEY}
    else
        echo "Certificate not exists."
        exit 1
    fi

    RPC_SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(16))')
    if [[ -f "${HOME}/.aria2/rpc_secrets.txt" ]]; then
        echo "Secrets exists."
    else
        echo "${RPC_SECRET_KEY}" > "${HOME}/.aria2/rpc_secrets.txt"
        echo "${RPC_SECRET_KEY} is your secret key." 
    fi
}

get_tracker(){
    ping -c 4 ngosang.github.io
    cd /tmp
    wget https://ngosang.github.io/trackerslist/trackers_all.txt
    if [[ "$?" -eq 0 ]]; then
        sed ':a;N;$!ba;s/\n\n/,/g' trackers_all.txt > /tmp/trackers.aria2 
        ALLTRACKERS=$(cat /tmp/trackers.aria2)
        rm /tmp/trackers.aria2
        rm /tmp/trackers_all.txt
    else
        echo "Failed to get trackers list."
        exit 1
    fi
}

init_cfg(){
    mkdir -p "${HOME}"/aria2dwd
    touch "${HOME}"/.aria2/aria2.session
    cat <<EOF > "${HOME}"/.aria2/aria2.conf
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
rpc-secret=$(cat ${HOME}/.aria2/rpc_secrets.txt)
rpc-secure=true
rpc-certificate=${CERTPATH}
rpc-private-key=${PRIVKEY}

follow-torrent=true
listen-port=15341
bt-max-peers=500
enable-dht=${SETTINGS_DHT}
enable-dht6=${SETTINGS_DHT}
#dht-listen-port=16881-16999
bt-enable-lpd=${SETTINGS_DHT}
enable-peer-exchange=${SETTINGS_DHT}
#bt-request-peer-speed-limit=50K

peer-id-prefix=-TR2770-
user-agent=Transmission/2.77

seed-ratio=1.5
seed-time=90
#force-save=false
bt-hash-check-seed=true
bt-seed-unverified=true
#bt-save-metadata=true

bt-tracker=${ALLTRACKERS}
EOF
}

restart_serv(){
    systemctl restart aria2
}

main(){
    check_env
    build_certpath
    get_tracker
    init_cfg
}

main
