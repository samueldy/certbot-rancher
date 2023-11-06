#!/bin/bash

# Preserve environment variables for cron jobs
printenv >/etc/environment

# Need to wait for cron volume mount to become available
sleep 10

# Delete any references to hooks in the certbot renewal config.
sed -i -e '/hook/d' /etc/letsencrypt/renewal/alloy-synthesis.che.engin.umich.edu.conf

# Ensure that the logs folder is created
mkdir -p "$LOGSDIR"

# Install certbot hooks
mkdir -p /etc/letsencrypt/renewal-hooks/{pre,post,deploy}
rm /etc/letsencrypt/renewal-hooks/pre/open_pgadmin_access.sh
rm /etc/letsencrypt/renewal-hooks/post/close_pgadmin_access.sh
rm /etc/letsencrypt/renewal-hooks/deploy/update_rancher.sh
ln -s /scripts/open_pgadmin_access.sh /etc/letsencrypt/renewal-hooks/pre/open_pgadmin_access.sh
ln -s /scripts/close_pgadmin_access.sh /etc/letsencrypt/renewal-hooks/post/close_pgadmin_access.sh
ln -s /scripts/update_rancher.sh /etc/letsencrypt/renewal-hooks/deploy/update_rancher.sh

# Entrypoint to run cron daemon instead of the certbot CLI. Run in foreground
# so container doesn't error out.
/usr/sbin/crond -f -l 2 -L /dev/stdout 2>/dev/stderr
