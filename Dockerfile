FROM alpine:latest

RUN apk update && \
    apk add --no-cache git curl bash

RUN adduser -D builder

ADD *.sh /home/builder/

USER builder

RUN chmod 555 /home/builder/*.sh

ENTRYPOINT ["/home/builder/entrypoint.sh"]
