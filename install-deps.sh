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

replace_apt(){
    cat <<EOF >/etc/apt/sources.list
deb http://deb.debian.org/debian buster main contrib non-free
deb http://security.debian.org/ buster/updates main contrib non-free
deb http://deb.debian.org/debian buster-updates main contrib non-free
deb http://deb.debian.org/debian buster-backports main
EOF
}

check_wg(){
    apt update -y
    apt upgrade -y
    apt install virt-what -y
    VMHYPERVISOR=$(virt-what)
    if [[ ${VMHYPERVISOR} == "kvm" || ${VMHYPERVISOR} == "hyperv" || ${VMHYPERVISOR} == "vmware" || "$?" -e 0 ]]; then
        echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list
        printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable
        apt install wireguard -y
    fi
}

update_soft(){
    apt install aria2 amule-daemon amule-emc amule-utils build-essentials git curl wget ca-certificates zstd psmisc socat -y
    apt install python3 python3-distutils -y
    curl -sSL -O https://bootstrap.pypa.io/get-pip.py 
    python3 ./get-pip.py
    python3 -m pip install requests
    rm ./get-pip.py
}

install_acmesh(){
    mkdir -p /etc/acme_certs
    git clone https://github.com/acmesh-official/acme.sh.git
    cd ./acme.sh
    ./acme.sh --install --cert-home /etc/acme_certs
    chown -R www-data:www-data /etc/acme_certs
    cd ..
    rm -rf ./acme.sh
}

install_caddyv1(){
    wget https://filebin.kmahyyg.xyz/caddy_v1.tar.zst
    zstd -d caddy_v1.tar.zst
    tar xvf caddy_v1.tar
    mv ./caddy /usr/local/bin/caddy
    chmod +x /usr/local/bin/caddy
    setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy
    rm -f ./caddy_v1.tar ./caddy_v1.tar.zst
    touch /etc/Caddyfile
}

main() {
    check_distro
    replace_apt
    check_wg
    update_soft
    install_acmesh
    echo "All Done! Run acme.sh to get certificates and go next steps."
    echo "The acme.sh documents can be found here: https://github.com/acmesh-official/acme.sh ."
}

main
