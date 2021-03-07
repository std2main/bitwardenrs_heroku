##################  RUNTIM IMAGE  ###################
# Create from wellbuilt bitwardenrs
# 1. Add needed package for rclone
# 2. Modify start.sh to suit in heroku enviroment
from bitwardenrs/server:alpine

COPY heroku_start.sh /heroku_start.sh

WORKDIR /
ENTRYPOINT ["usr/bin/dumb-init", "--"]
CMD ["/heroku_start.sh"]
