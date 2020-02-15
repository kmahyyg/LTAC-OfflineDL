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


install_serv(){
    cp -af /usr/local/ltactools/services/*.service /etc/systemd/system/
    cp -af /usr/local/ltactools/services/*.timer /etc/systemd/system/
    systemctl daemon-reload
}

add_sudoers(){
    cat <<EOF >>/etc/sudoers
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
