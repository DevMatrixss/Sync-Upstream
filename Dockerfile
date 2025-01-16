FROM alpine:latest

RUN apk update && \
    apk add --no-cache git curl bash

RUN adduser -D builder

ADD *.sh /home/builder/

WORKDIR /home/builder

USER root

RUN chmod 755 /home/builder/*.sh && \
    chown builder:builder /home/builder/*.sh  # Set the owner to builder

USER builder

ENTRYPOINT ["/home/builder/entrypoint.sh"]
