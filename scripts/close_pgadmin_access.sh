#!/bin/bash

# Script to unblock the PgAdmin4 ingress so that the Let's Encrypt CA can access it for renewal purposes.

# Import environment variables.
source /etc/environment

if [[ -z "${CONTEXT}" ]]; then
    echo "CONTEXT enviroment variable must be defined." 1>&2
    exit 1
fi

if [[ -z "${NAMESPACE}" ]]; then
    echo "NAMESPACE enviroment variable must be defined." 1>&2
    exit 1
fi

if [[ -z "${ENDPOINT_URL}" ]]; then
    echo "ENDPOINT_URL enviroment variable must be defined." 1>&2
    exit 1
fi

if [ ! -f /secrets/bearer-token ]; then
    echo "/secrets/bearer-token secret must be mounted." 1>&2
    exit 1
fi

# Log into Rancher
rancher login --token $(cat /secrets/bearer-token) $ENDPOINT_URL --context $CONTEXT

# Restore the allowed-IP annotation so that the PgAdmin4 ingress is no longer public
rancher kubectl -n $NAMESPACE annotate --overwrite ingress "pgadmin4-main" "nginx.ingress.kubernetes.io/whitelist-source-range"="$(cat /tmp/pgadmin4-allowed-ips.txt)"

# Remove record of allowed IPs.
rm /tmp/pgadmin4-allowed-ips.txt
