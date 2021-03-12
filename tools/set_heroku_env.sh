#!/bin/bash

env_file="${1:-.env}"
cat "${env_file}" | grep -v '#' | grep '=' | xargs heroku config:set
