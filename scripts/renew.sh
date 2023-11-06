#!/bin/sh
LOGSDIR=/var/spool/anacron-store/logs

# Specify forced renewal so that we can let the cron job take care of
# auto-renewing before the certificate is expired. Like every 60 days.
certbot renew --force-renewal --deploy-hook /scripts/update_rancher.sh &&
    echo "TLS certs renewed as of $(date -Is)." 2>&1 | tee -a $LOGSDIR/anacrontab-output.log
