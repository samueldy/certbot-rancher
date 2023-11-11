#!/bin/sh

# Script to unblock the PgAdmin4 ingress so that the Let's Encrypt CA can access it for renewal purposes.

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

# Retrieve the annotation for allowed IPs, store to temporary value
rancher kubectl -n $NAMESPACE get ingress "pgadmin4-main" -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/whitelist-source-range}' >/tmp/pgadmin4-allowed-ips.txt

# Now delete that annotation so that all IPs (including those of Let's Encrypt
# CA) can access the site.
rancher kubectl -n $NAMESPACE annotate ingress "pgadmin4-main" "nginx.ingress.kubernetes.io/whitelist-source-range"-
