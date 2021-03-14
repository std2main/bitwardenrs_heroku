##################  RUNTIM IMAGE  ###################
from bitwardenrs/server:alpine

RUN apk add --no-cache git
RUN apk add --no-cache openssh
RUN apk add --no-cache inotify-tools
RUN apk add --no-cache bash
RUN apk add --no-cache unison
RUN apk add --no-cache incron

ENV _BAK_FILE_REPO=/bak_file

# Limit size of attachment to 10M for normal usage, git is not suitable for handle large files.
ENV ORG_ATTACHMENT_LIMIT=10240
ENV USER_ATTACHMENT_LIMIT=10240
ENV LOG_LEVEL=error

ADD git_backup.sh /git_backup.sh
ADD heroku_start.sh /heroku_start.sh
#ADD incron_sync.sh /incron_sync.sh
ADD polling_backup.sh /polling_backup.sh

WORKDIR /
ENTRYPOINT ["usr/bin/dumb-init", "--"]
CMD ["/heroku_start.sh"]
