##################  RUNTIM IMAGE  ###################
from bitwardenrs/server:alpine

RUN apk add git
RUN apk add openssh

ADD git_backup.sh /git_backup.sh
ADD heroku_start.sh /heroku_start.sh

WORKDIR /
ENTRYPOINT ["usr/bin/dumb-init", "--"]
CMD ["/heroku_start.sh"]
