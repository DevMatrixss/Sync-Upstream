FROM alpine:latest

RUN apk add --no-cache git curl bash ca-certificates shadow && \
    addgroup -g 1001 builder && adduser -D -u 1001 -G builder builder

COPY entrypoint.sh /home/builder/
RUN chmod +x /home/builder/entrypoint.sh

USER builder

WORKDIR /home/builder
ENTRYPOINT ["/home/builder/entrypoint.sh"]
