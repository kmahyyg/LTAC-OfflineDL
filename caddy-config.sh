#!/bin/bash

FDPATH=$1
DOMAIN=$2

certconf(){
    CERTPATH="${FDPATH}/${DOMAIN}/fullchain.cer"
    PRIVKEY="${FDPATH}/${DOMAIN}/${DOMAIN}.key"
    if [[ -f ${CERTPATH} && -f ${PRIVKEY} ]]; then
        echo ${CERTPATH}
        echo ${PRIVKEY}
    else
        echo "Certificate not exists."
        exit 1
    fi
}

usrpwd(){
    GENPWD=$(python -c 'import secrets; print(secrets.token_urlsafe(12))')
    GENUSR=$(python -c 'import secrets; print(secrets.token_hex(3))')
    echo "USERNAME: ${GENUSR}"
    echo "PASSWORD: ${GENPWD}"
}

caddyconf(){
    cat <<EOF >/etc/Caddyfile
https://${DOMAIN}/ed2kd/ {
    tls ${CERTPATH} ${PRIVKEY}
    root /home/amuled/amuledwd
    gzip 
    browse
    basicauth / ${GENUSR} ${GENPWD}
}

https://${DOMAIN}/aria2w/ {
    tls ${CERTPATH} ${PRIVKEY}
    root /home/aria2/ariang
    gzip
}

https://${DOMAIN}/ed2kw/ {
    tls ${CERTPATH} ${PRIVKEY}
    proxy / 127.0.0.1:4711 {
        transparent
    }
}

https://${DOMAIN}/aria2d/ {
    tls ${CERTPATH} ${PRIVKEY}
    root /home/aria2/aria2dwd
    browse
    gzip
    basicauth / ${GENUSR} ${GENPWD}
}
EOF
}

main(){
    certconf
    usrpwd
    caddyconf
}

main
