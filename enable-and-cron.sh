#!/bin/bash

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
}

check_distro
systemctl enable --now aria2
systemctl enable --now caddy
systemctl start aria-tracker-update.service
systemctl enable aria-tracker-update.timer
systemctl enable --now amuled
systemctl enable --now amule-web
