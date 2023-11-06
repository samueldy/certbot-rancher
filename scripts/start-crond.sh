#!/bin/bash

# Preserve environment variables for cron jobs
printenv > /etc/environment

# Need to wait for cron volume mount to become available
sleep 10

# Make necessary anacron timestamp and log directories if they don't already
# exist.
mkdir -p /var/spool/anacron-store/anacron
mkdir -p /var/spool/anacron-store/logs

# Delete any references to hooks in the certbot renewal config.
sed -i -e '/hook/d' /etc/letsencrypt/renewal/alloy-synthesis.che.engin.umich.edu.conf

# Entrypoint to run cron daemon instead of the certbot CLI. Run in foreground
# so container doesn't error out.
/usr/sbin/crond -n >/dev/stdout 2>/dev/stderr
