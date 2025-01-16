FROM alpine:latest

RUN apk update && \
    apk add --no-cache git curl bash

RUN adduser -D builder

ADD *.sh /home/builder/

WORKDIR /home/builder

USER root

RUN chmod 555 /home/builder/*.sh

USER builder

ENTRYPOINT ["/home/builder/entrypoint.sh"]
