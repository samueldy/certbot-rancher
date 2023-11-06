#!/bin/bash
LOGSDIR=/var/spool/anacron-store/logs

# Specify forced renewal so that we can let the cron job take care of
# auto-renewing before the certificate is expired. Like every 60 days.

# First need to open access to the PgAdmin4 ingress, then need to do cert
# renewal and push updated certs to Rancher's secrets store. Wait a little
# after opening ingress to avoid race condition where certbot tries to read the
# well-known ACME challenge before that ingress endpoint is actually unblocked.
/scripts/open_pgadmin_access.sh
sleep 10

# Do the renewal.
certbot renew --force-renewal 2>&1 | tee -a $LOGSDIR/anacrontab-output.log

# Update Rancher separately, because using this script as a deploy hook somehow
# drops the $DOMAIN variable.
/scripts/update_rancher.sh 2>&1 | tee -a $LOGSDIR/anacrontab-output.log

# Log attempt.
echo "Attempted to renew TLS certs as of $(date -Is)." 2>&1 | tee -a $LOGSDIR/anacrontab-output.log

# Finally, re-protect PgAdmin4 ingress.
/scripts/close_pgadmin_access.sh
