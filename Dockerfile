FROM alpine:latest

RUN apk add --no-cache git curl bash ca-certificates shadow && \
    adduser -D builder

COPY entrypoint.sh /home/builder/
RUN chmod +x /home/builder/entrypoint.sh && \
    chown builder:builder /home/builder/entrypoint.sh

USER builder
WORKDIR /home/builder
ENTRYPOINT ["/home/builder/entrypoint.sh"]
