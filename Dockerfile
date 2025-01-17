FROM alpine:latest

RUN apk update && \
    apk add --no-cache git curl bash ca-certificates shadow

RUN adduser -D -u 1001 builder

COPY ./*.sh /home/builder/

WORKDIR /home/builder

USER builder

RUN ls -l /home/builder/  # जांचें कि फ़ाइलें सही ढंग से कॉपी हो रही हैं

RUN chmod +x /home/builder/*.sh

ENTRYPOINT ["/home/builder/entrypoint.sh"]
