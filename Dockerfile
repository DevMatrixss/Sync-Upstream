FROM alpine:latest

RUN apk update && apk add --no-cache \
    git \
    curl \
    bash

RUN adduser -D builder

WORKDIR /home/builder

COPY *.sh /home/builder/

RUN chmod +x /home/builder/*.sh

USER builder

ENTRYPOINT ["/home/builder/entrypoint.sh"]
