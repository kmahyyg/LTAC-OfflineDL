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
    if [[ ${VMHYPERVISOR} == "kvm" || ${VMHYPERVISOR} == "hyperv" || ${VMHYPERVISOR} == "vmware" || "$?" -eq 0 ]]; then
        echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list
        printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable
        apt update -y
        apt install wireguard -y
    fi
}

update_soft(){
    apt install aria2 amule-daemon amule-emc amule-utils build-essential sudo git curl wget unzip ca-certificates zstd psmisc socat -y
    apt install python3 python3-distutils -y
    curl -sSL -O https://bootstrap.pypa.io/get-pip.py 
    python3 ./get-pip.py
    python3 -m pip install requests
    rm ./get-pip.py
    rm -rf /usr/local/ltactools
    mkdir -p /usr/local/ltactools
    cp -af . /usr/local/ltactools
}

install_acmesh(){
    mkdir -p /etc/acme_certs
    git clone https://github.com/acmesh-official/acme.sh.git
    cd ./acme.sh || exit 3
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
    chown www-data:www-data /etc/Caddyfile
}

create_usrs(){
    useradd -s "$(which nologin)" -m -U aria2
    useradd -s "$(which nologin)" -m -U amuled
    usermod -aG aria2 www-data
    usermod -aG www-data aria2
    usermod -aG amuled www-data
    usermod -aG www-data amuled
}

dwnld_ariang(){
    wget "https://github.com/mayswind/AriaNg/releases/download/1.1.4/AriaNg-1.1.4-AllInOne.zip"
    mkdir -p /home/aria2/ariang
    unzip -d /home/aria2/ariang AriaNg-1.1.4-AllInOne.zip
    chown -R aria2:aria2 /home/aria2/ariang
    rm /home/aria2/ariang/LICENSE
    rm AriaNg-1.1.4-AllInOne.zip
}

main() {
    check_distro
    replace_apt
    check_wg
    update_soft
    install_acmesh
    install_caddyv1
    create_usrs
    dwnld_ariang
    echo "All Done! Run acme.sh to get certificates and go next steps."
    echo "The acme.sh documents can be found here: https://github.com/acmesh-official/acme.sh ."
}

main
