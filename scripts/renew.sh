#!/bin/sh

# Specify forced renewal so that we can let the cron job take care of
# auto-renewing before the certificate is expired. Like every 60 days.
certbot renew --force-renewal --deploy-hook /scripts/update_rancher.sh