##################  RUNTIM IMAGE  ###################
from bitwardenrs/server:alpine

RUN apk add --no-cache git
RUN apk add --no-cache openssh
RUN apk add --no-cache inotify-tools
RUN apk add --no-cache bash

# Limit size of attachment to 10M for normal usage, git is not suitable for handle large files.
ENV ORG_ATTACHMENT_LIMIT=10240
ENV USER_ATTACHMENT_LIMIT=10240
ENV LOG_LEVEL=error

ADD git_backup.sh /git_backup.sh
ADD heroku_start.sh /heroku_start.sh
ADD inotify_backup_db.sh /inotify_backup_db.sh
ADD inotify_backup_file.sh /inotify_backup_file.sh

WORKDIR /
ENTRYPOINT ["usr/bin/dumb-init", "--"]
CMD ["/heroku_start.sh"]
