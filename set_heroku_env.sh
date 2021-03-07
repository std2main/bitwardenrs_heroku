#!/bin/bash

cat .env | grep -v '#' | grep '=' | xargs heroku config:set
