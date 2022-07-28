# [bitwardenrs_heroku](https://dashboard.heroku.com/new?template=https://github.com/OldTyT/bitwardenrs_heroku)
Run [bitwarden_rs](https://github.com/dani-garcia/bitwarden_rs) on heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Based on official bitwarden_rs docker image, added customized scripts to setup in heroku enviroment.

## Goal
* Deploy a reliable bitwarden for free as easy as possible.
  * Deploying: Almost no command line.
  * Maintainance: Almost zero. 
  * As more functions as budget support
    1. Essentials and backups.
    2. TODO: Realtime syncing cross multiple devices.
    3. TODO: Attachments.
    4. TODO: Icons.

## Why Heroku
* Bitwarden_rs is a lightweight service that able to run on heroku's free dyno ( < 512MB ram).
* Free quota (average 18 horus/day) lasts for one month when notification requests are blocked.
* Verified user have extensible free addons to make life easy, including database, logging, backup, etc.

## Features
* For verified heroku users
  * Postgresql Database for persistent storage.
  * Daily backup and monthly longterm backup.
  * Persistent rsa keys backed by config vars.
* For unverified heroku users
  * Please Try https://github.com/std2main/bitwardenrs_heroku/tree/git_store 


## Addons
* Heroku-Postgresql
  * Free tier provides 10000 rows that is enough for 10 people.
  * My 5 year old vault contains 800 passwords and consumed 1000 rows in pgsql.
* Autobus
  * Daily backups of postgresql.
  * Keep monthly backup for 1 year for free. [see more](https://devcenter.heroku.com/articles/autobus#backups-retention-limits)
  * **Important**, add 'heroku@autobus.io' as collabrator in https://dashboard.heroku.com/apps/YOUR_APP/access after creation.

## Limitation
* No Attachments.
* Admin Panel changes will be lost.
* No Icons.
  * [Official icon server](https://icons.bitwarden.net/) can be used if need icons, [see more](https://bitwarden.com/help/article/website-icons/). 

## TODO
* Auto Update
  * Github Action + Heroku, create a branch 'auto-update' to be used by heroku, this branch will periodically commit then triggers app rebuid in heroku to catch any updates of bitwarden_rs
* Unverified heroku user solution
  * Self owned DATABASE.
  * Persistent local storage tricks.

## FAQ
* Admin panel
  * Set **ENABLE_ADMIN**=**true** in heroku enviroment.
  * Use **GEN_ADMIN_TOKEN** as ADMIN_TOKEN. This is auto generated secret when app initialized.
* Configuration
  * All enviroment of heroku will be treated as enviroment of bitwarden_rs.
* Forcely loggout after a while
  * Run heroku_set_rsa.sh to enable persistent rsa key.
* App costs 24 dynos/day, aka it didn't sleep when idle.
  * Mostly caused by requests of '/notifications' and '/icons', [see more](https://github.com/dani-garcia/bitwarden_rs/issues/126)
  * Notifications are triggered every 4 minutes by chrome extension or desktop app.
  * Icons are triggered if icon server url is not set to others.
  * My method is to block them by Cloudflare firewall. 
