#!/bin/bash

SCRIPTS_HOME="$(dirname "$0")"

chmod -R 755 ${SCRIPTS_HOME}
sudo -u root -- bash ${SCRIPTS_HOME}/install-deps.sh
sudo -u aria2 -- bash ${SCRIPTS_HOME}/aria-trackers-upd.sh
sudo -u www-data -- bash ${SCRIPTS_HOME}/caddy-config.sh
sudo -u amuled -- bash ${SCRIPTS_HOME}/amule-config.sh
sudo -u root -- bash ${SCRIPTS_HOME}/install-serv.sh

echo "Do you wanna enable auto-update tracker and auto-start? (y/n)"
read autoupdch
case "$autoupdch" in
    'y')
        sudo -u root -- bash ${SCRIPTS_HOME}/enable-and-cron.sh
        ;;
esac

echo "All done."
