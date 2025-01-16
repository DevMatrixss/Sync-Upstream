FROM alpine:latest

RUN apk update && \
    apk add --no-cache git curl bash

RUN adduser -D builder

ADD *.sh /home/builder/

WORKDIR /home/builder

USER root

RUN chmod 555 /home/builder/*.sh

# builder यूजर को root UID और GID के रूप में सेट करें
RUN usermod -u 0 -o builder && groupmod -g 0 builder

USER builder

ENTRYPOINT ["/home/builder/entrypoint.sh"]
