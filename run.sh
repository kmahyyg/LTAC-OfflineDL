#!/bin/bash

sudo bash ./install-deps.sh
sudo bash ./aria-trackers-upd.sh
sudo bash ./caddy-config.sh
sudo bash ./amule-config.sh

echo "Do you wanna enable auto-update tracker and auto-start? (y/n)"
read autoupdch
case "$autoupdch" in
    'y')
        sudo bash ./enable-and-cron.sh
        ;;
esac
