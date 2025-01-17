FROM alpine:latest

RUN apk update && \
    apk add --no-cache git curl bash ca-certificates

RUN adduser -D -u 1001 builder

ADD *.sh /home/builder/

WORKDIR /home/builder

USER builder

RUN chmod +x /home/builder/*.sh

ENTRYPOINT ["/home/builder/entrypoint.sh"]
