FROM alpine:latest

RUN apk update && \
    apk add --no-cache git curl bash

RUN adduser -D builder

ADD *.sh /home/builder/

WORKDIR /home/builder

USER builder

ENTRYPOINT ["/bin/sh", "-c", "chmod 555 /home/builder/*.sh && /home/builder/entrypoint.sh"]
