FROM alpine:latest

RUN apk update && \
    apk add --no-cache git curl bash

RUN adduser -D -u 1001 builder

ADD *.sh /home/builder/

WORKDIR /home/builder

USER builder

RUN chmod 555 /home/builder/*.sh

ENTRYPOINT ["/home/builder/entrypoint.sh"]
