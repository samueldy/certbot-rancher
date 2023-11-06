#!/bin/bash

# Log the cert renewal attempt.
echo "Attempted to renew TLS certs as of $(date -Is)." 2>&1 >>"$LOGSDIR/renew-log"

# Do the renewal. Certbot should run the hook scripts automatically.
certbot renew 2>&1 >>"$LOGSDIR/renew-log"
