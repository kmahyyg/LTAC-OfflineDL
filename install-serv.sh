#!/bin/bash

FDPATH=$1
DOMAIN=$2
PT_ENABLED=$3

check_distro() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root."
        exit 1
    fi

    if [[ $(lsb_release -i | cut -f 2-) != "Debian" ]]; then
        echo "Only runs on Debian 10."
        exit 1
    fi

    if [[ $(lsb_release -r | cut -f 2-) -ne 10 ]]; then
        echo "Only runs on Debian 10."
        exit 1
    fi

    echo "123456" > /root/.48l3phw23fp.placeholder
    if [[ "$?" -ne 0 ]]; then
        echo "Failed to get root permission."
        exit 1
    fi
    rm /root/.48l3phw23fp.placeholder

    if [[ -z ${FDPATH} || -z ${DOMAIN} ]]; then
        echo "PLEASE OFFER CERT FOLDER PATH AND DOMAIN NAME."
        exit 1
    fi
}

add_tracker_upd(){
    sync
    echo "FDPATH: ${FDPATH}"
    echo "DOMAIN: ${DOMAIN}"
    echo "PT: ${PT_ENABLED}"
    cat <<EOF >/etc/systemd/system/aria-tracker-update.service
[Unit]
Description=Automatically update trackers and restart aria2
Wants=network.target network-online.target
After=network.target network-online.target

[Service]
User=aria2
Type=oneshot

EOF

    echo "ExecStart=/bin/bash /usr/local/ltactools/aria-trackers-upd.sh ${FDPATH} ${DOMAIN} ${PT_ENABLED}" >> /etc/systemd/system/aria-tracker-update.service

    cat <<EOF >>/etc/systemd/system/aria-tracker-update.service

[Install]
WantedBy=multi-user.target
EOF
    sync
    sync
    cat /etc/systemd/system/aria-tracker-update.service
}

install_serv(){
    add_tracker_upd
    cp -af /usr/local/ltactools/services/*.service /etc/systemd/system/
    cp -af /usr/local/ltactools/services/*.timer /etc/systemd/system/
    systemctl daemon-reload
}

add_sudoers(){
    cat <<EOF >/etc/sudoers.d/91-ltactools
%www-data ALL=(root) NOPASSWD: /usr/bin/systemctl restart caddy
%aria2 ALL=(root) NOPASSWD: /usr/bin/systemctl restart aria2
%aria2 ALL=(root) NOPASSWD: /usr/bin/systemctl start aria-tracker-update
%amuled ALL=(root) NOPASSWD: /usr/bin/systemctl restart amuled
%amuled ALL=(root) NOPASSWD: /usr/bin/systemctl restart amule-web
EOF
}

main(){
    check_distro
    install_serv
    add_sudoers
}

main
