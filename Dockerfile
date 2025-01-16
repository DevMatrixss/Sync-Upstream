FROM alpine:latest

RUN apk update && \
    apk add --no-cache git curl bash

RUN adduser -D builder

ADD *.sh /home/builder/

WORKDIR /home/builder

USER root

RUN chmod 755 /home/builder/*.sh  # Read, Write, and Execute for owner, Read and Execute for group and others

USER builder

ENTRYPOINT ["/home/builder/entrypoint.sh"]
