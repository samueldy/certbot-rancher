if [[ -z "${DOMAIN}" ]]; then
    echo "DOMAIN enviroment variable must be defined." 1>&2
    exit 1
fi

if [[ -z "${LIVE_DOMAIN_FOLDER_NAME}" ]]; then
    echo "LIVE_DOMAIN_FOLDER_NAME enviroment variable must be defined." 1>&2
    exit 1
fi

if [[ -z "${CONTEXT}" ]]; then
    echo "CONTEXT enviroment variable must be defined." 1>&2
    exit 1
fi

if [[ -z "${CERT_NAME}" ]]; then
    echo "CERT_NAME enviroment variable must be defined." 1>&2
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

CERT_PATH=/etc/letsencrypt/live/$LIVE_DOMAIN_FOLDER_NAME/fullchain.pem
KEY_PATH=/etc/letsencrypt/live/$LIVE_DOMAIN_FOLDER_NAME/privkey.pem

rancher login --token $(cat /secrets/bearer-token) $ENDPOINT_URL --context $CONTEXT

rancher kubectl -n $NAMESPACE create secret tls $CERT_NAME --cert=$CERT_PATH \
    --key=$KEY_PATH --dry-run=client --save-config -o yaml | rancher kubectl apply -f -
