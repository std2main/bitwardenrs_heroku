# bitwardenrs_heroku
Run [bitwarden_rs](https://github.com/dani-garcia/bitwarden_rs) on heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Introduction
Based on official bitwarden_rs docker image, added customized scripts to setup in heroku enviroment.

## Addons
* Heroku-Postgresql
  * Free tier provides 10000 rows that is enough for 10 people.
  * My 5 year old vault contains 800 passwords and consumed 1000 rows in pgsql.
* Autobus
  * Daily backups of postgresql.
  * Keep monthly backup for 1 year for free.
  * **Important**, add 'heroku@autobus.io' as collabrator in https://dashboard.heroku.com/apps/YOUR_APP/access after creation.

## Limitation
* No Attachments.
* Admin Panel changes will be lost.
* No Icons.
  * [Official icon server](https://icons.bitwarden.net/) can be used if need icons, [see more](https://bitwarden.com/help/article/website-icons/). 

## FAQ
* Admin panel
  * Set **ENABLE_ADMIN**=**true** in heroku enviroment.
  * Use **GEN_ADMIN_TOKEN** as ADMIN_TOKEN. This is auto generated secret when app initialized.
* Configuration
  * All enviroment of heroku will be treated as enviroment of bitwarden_rs.
