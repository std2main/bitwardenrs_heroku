#!/bin/sh
# Let rocket bind heroku port
export ROCKET_PORT="${PORT}"

# Do not use local storage
# TODO: Store rsa_key in db or env 
export ORG_ATTACHMENT_LIMIT=0
export USER_ATTACHMENT_LIMIT=0
export DISABLE_ICON_DOWNLOAD=true
export ICON_CACHE_TTL=0
export ICON_CACHE_NEGTTL=0

if [ "${ENABLE_ADMIN}" == "true" ]; then
  echo "ENABLE ADMIN"
  export ADMIN_TOKEN="${GEN_ADMIN_TOKEN}"
else
  echo "DISABLE ADMIN"
  unset ADMIN_TOKEN
fi

if [ -z "${RSA_CONTENT}" ]; then
  echo "RSA CONTENT not set"
else
  echo "Restore rsa content"
  echo "${RSA_CONTENT}" | base64 -d | tar zxf -
  export RSA_KEY_FILENAME=${PWD}/rsa_key
fi

# TODO: Warning or refuse to start when DATABASE_URL is not set

/bin/sh /start.sh
