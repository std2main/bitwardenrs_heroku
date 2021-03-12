##################  RUNTIM IMAGE  ###################
from bitwardenrs/server:alpine

RUN apk add git
RUN apk add openssh

ENV BACKUP_DB_REPO="/backup_db"
ENV BACKUP_FILE_REPO="/backup_file"
ENV DATABASE_URL="/db.sqlite3"

ENV ORG_ATTACHMENT_LIMIT=10240
ENV USER_ATTACHMENT_LIMIT=10240
ENV DISABLE_ICON_DOWNLOAD=false
ENV ICON_CACHE_TTL=2592000
ENV ICON_CACHE_NEGTTL=259200
ENV LOG_LEVEL=error

ADD git_backup.sh /git_backup.sh
ADD heroku_start.sh /heroku_start.sh

WORKDIR /
ENTRYPOINT ["usr/bin/dumb-init", "--"]
CMD ["/heroku_start.sh"]
