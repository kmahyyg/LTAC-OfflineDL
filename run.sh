#!/bin/bash

SCRIPTS_HOME="$(dirname "$0")"

chmod -R 755 "${SCRIPTS_HOME}"
sudo -u root -- bash "${SCRIPTS_HOME}"/install-deps.sh

echo "We will invoke another shell for you to do the HTTPS cert sign up via acme.sh ."
echo "After you signed cert, please input domain name."
sudo -i

echo "What's your domain name?"
read -r CHOICE1
echo "Do you use PT? (y/n)"
read -r CHOICE2
PT_OPTION=0
case $CHOICE2 in
    'y')
        PT_OPTION=1
        ;;
esac

sudo -u aria2 -- bash "${SCRIPTS_HOME}"/aria-trackers-upd.sh "/etc/acme_certs" "${CHOICE1}" "${PT_OPTION}"
sudo -u www-data -- bash "${SCRIPTS_HOME}"/caddy-config.sh "/etc/acme_certs" "${CHOICE1}"
sudo -u root -- bash -c "chown root:root /etc/Caddyfile"
sudo -u amuled -- bash "${SCRIPTS_HOME}"/amule-config.sh
sudo -u root -- bash "${SCRIPTS_HOME}"/install-serv.sh

echo "Do you wanna enable auto-update tracker and auto-start? (y/n)"
read -r autoupdch
case "$autoupdch" in
    'y')
        sudo -u root -- bash "${SCRIPTS_HOME}"/enable-and-cron.sh
        ;;
esac

echo "All done."
