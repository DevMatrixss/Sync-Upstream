FROM alpine:latest

RUN apk update && \
    apk add --no-cache git curl bash ca-certificates shadow

RUN adduser -D -u 1001 builder

COPY ./*.sh /home/builder/

# बदल दिया गया स्थान: chmod को COPY के बाद रखा गया
RUN chmod +x /home/builder/*.sh

WORKDIR /home/builder

USER builder

ENTRYPOINT ["/home/builder/entrypoint.sh"]
