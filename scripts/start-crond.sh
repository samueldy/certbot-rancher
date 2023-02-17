#!/bin/sh

# Need to wait for cron volume mount to become available
sleep 10

# Entrypoint to run cron daemon instead of the certbot CLi
/usr/sbin/crond -f -l 2 -L /dev/stdout 2>/dev/stderr
