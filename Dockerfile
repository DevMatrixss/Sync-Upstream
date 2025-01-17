FROM alpine:latest

RUN apk add --no-cache git curl bash ca-certificates shadow && \
    adduser -D builder

COPY entrypoint.sh /home/builder/
RUN chmod +x /home/builder/entrypoint.sh && \
    chown -R builder /home/builder

USER builder
WORKDIR /home/builder
ENTRYPOINT ["./entrypoint.sh"]
