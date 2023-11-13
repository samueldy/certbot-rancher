
This repository can be used to build two images to generate and install
certificates using certbot in a Rancher environment. Note that if you have the
required admin permissions you should look at a cert-manager based solution.

This repository builds two containers:

- `Dockerfile.nginx` (openchemistry/certbot-nginx) - A nginx container that
  will expose `.well-known/acme-challenge` for a give host. The NGINX_HOST
  environment variable is used to set `server_name`.
- `Dockerfile.rancher` openchemistry/certbot-rancher) - A certbot/certbot based
  container with add hooks to copy certificates into a Rancher certificate.

# Usage

Several workloads need to be created from the two images.

## NGINX workload

This workload needs to be created from the `openchemistry/certbot-nginx` image.
It expose a `.well-known/acme-challenge` file that is generated by certbot. A
volume should mounted at `/usr/share/nginx/html`, this volume will also be
mounted into the second workload.

### Configuration

The following environment variables must be configured on the workload:

- `NGINX_HOST` - This should be the domain that a certificate is being
  requested for.

The appropriate ingress should be setup to allow 80 to be routed to this
workload.

## Certbot workloads

The `Dockerfile.certbot` container is used to do both (1) and initial setup of
your website with Let's Encrypt (accomplished by a one-time run of the script
`/scripts/setup.sh`) and (2) the periodic renewal of your site's certificate
(with each renewal accomplished by running the script `/scripts/renew.sh`).
Because the `certbot` utility by default renews certs only when needed (with a
default renewal every 60 days [following
recommendations](https://letsencrypt.org/docs/faq/#:~:text=Our%20certificates%20are%20valid%20for,your%20certificates%20every%2060%20days)),
there's no need for something like `anacron`—we can just have `cron` run
`certbot renew` every day, and `certbot` will ensure that the certs are renewed
only when needed.

This certbot workload needs to be created from the
`openchemistry/certbot-rancher` and is be used to execute the certbot commands
necessary to setup and renew certs. The volume attached to the NGINX workload
should be mount to `/data/letsencrypt`, which is where `certbot` will write the
challenge. A second volume should be mounted at `/etc/letsencrypt`, which is
where `certbot` will write the certificates obtained from the Let's Encrypt CA.

### Configuration

The following environment variables must be configured on these workloads:

- `DOMAIN` - The domain that the SSL cert is to be generated for. Can be a
  single domain, or a comma-separated list of domains.
- `LIVE_DOMAIN_FOLDER_NAME` - The name of the folder in /etc/letsencrypt/live
  that contains the certs obtained from the CA. Normally this is the same as
  $DOMAIN if you are requesting certs for a single domain. If there are
  multiple domains specified in $DOMAIN, this variable is the name of the first
  domain in that list.
- `CERT_NAME` - The name to give the SSL cert in Rancher.
- `NAMESPACE` - The Rancher namespace to create the certificate in.
- `ENDPOINT_URL` - The to use to login to Rancher (for example:
  https://rancher2.spin.nersc.gov/v3).
- `CONTEXT` - The rancher project id.
- `EMAIL` - The email for certbot to use for notifications.
- `LOGSDIR` - the location where you want logs from the `renew.sh` script
  described below to be stored. These can be put inside the image's temporary
  filesystem (e.g., somewhere under `/var/log`) or somewhere in persistent
  storage if you want to retain them.

The following secret should be mounted into the workload:
- `/secrets/bearer-token` - This should contain the bearer token to be used for
  `rancher login`.


### Script

The image provides some scripts that can be used as entrypoints:

- `/scripts/setup.sh` - Run to create the initial certificate.
- `/scripts/renew.sh` - Run periodically to renew the certificate it necessary.
- `/scripts/open_pgadmin_access.sh` and `/scripts/close_pgadmin_access.sh` -
  Unblock and reblock the Kubernetes Nginx-class ingress exposing our PgAdmin4
  service. Normally the ingress should remain IP-blocked to all but a few IP
  addresses, but it's necessary to temporarily open the ingress in order to
  renew its certificate.
- `/scripts/update_rancher.sh` - post-renewal deploy hook script for certbot to
  push the newly obtained certificates to NERSC's Kubernetes instance using the
  Rancher CLI.
- `/scripts/start-crond.sh` - Entrypoint script to start the `cron` daemon
  instead of running `certbot`.


Once the initial setup workload job has been execute a Rancher certificate will
have been created and can be used by the appropriate ingress.