#!/usr/bin/env bash

set -e

# Setting Colors
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' #No Color
NOW=$(date "+%Y-%m-%d_%H-%M-%S")


if [ "${IAC_MODE}" == "standalone" ]; then


   mkdir -p /etc/letsencrypt
   # Renew existing cert or build
   certbot renew -n --agree-tos --dns-route53 --dns-route53-propagation-seconds 60 --cert-name ${IAC_CERTBOT_DOMAIN} -m ${IAC_CERTBOT_EMAIL} || certbot certonly -n --agree-tos --dns-route53 --dns-route53-propagation-seconds 60 -d ${IAC_CERTBOT_DOMAIN} -d *.${IAC_CERTBOT_DOMAIN} -m ${IAC_CERTBOT_EMAIL}

else

  # Init certbot cache
  mkdir -p /etc/letsencrypt
  aws s3 sync s3://${IAC_CERTBOT_CACHE} /etc/letsencrypt

  # Cleanup symblinks
  rm -f /etc/letsencrypt/live/${IAC_CERTBOT_DOMAIN}/*.pem || true
  ln -s /etc/letsencrypt/archive/${IAC_CERTBOT_DOMAIN}/cert*.pem /etc/letsencrypt/live/${IAC_CERTBOT_DOMAIN}/cert.pem || true
  ln -s /etc/letsencrypt/archive/${IAC_CERTBOT_DOMAIN}/chain*.pem /etc/letsencrypt/live/${IAC_CERTBOT_DOMAIN}/chain.pem || true
  ln -s /etc/letsencrypt/archive/${IAC_CERTBOT_DOMAIN}/fullchain*.pem /etc/letsencrypt/live/${IAC_CERTBOT_DOMAIN}/fullchain.pem || true
  ln -s /etc/letsencrypt/archive/${IAC_CERTBOT_DOMAIN}/privkey*.pem /etc/letsencrypt/live/${IAC_CERTBOT_DOMAIN}/privkey.pem || true

  # Renew existing cert or build
  certbot renew -n --agree-tos --dns-route53 --dns-route53-propagation-seconds 60 --cert-name ${IAC_CERTBOT_DOMAIN} -m ${IAC_CERTBOT_EMAIL} || certbot certonly -n --agree-tos --dns-route53 --dns-route53-propagation-seconds 60 -d ${IAC_CERTBOT_DOMAIN} -d *.${IAC_CERTBOT_DOMAIN} -m ${IAC_CERTBOT_EMAIL}

  # Update certbot cache
  aws s3 sync /etc/letsencrypt s3://${IAC_CERTBOT_CACHE}
fi

