FROM alpine:latest

RUN apk add --no-cache git curl bash ca-certificates shadow && \
    addgroup -g 1001 builder && adduser -D -u 1001 -G builder builder

COPY entrypoint.sh /usr/local/bin/ && chmod +x /usr/local/bin/entrypoint.sh
USER builder

WORKDIR /home/builder
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
