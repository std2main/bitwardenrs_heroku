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

# TODO: Warning or refuse to start when DATABASE_URL is not set

/bin/sh /start.sh
