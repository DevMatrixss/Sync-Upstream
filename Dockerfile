FROM alpine:latest

RUN apk update && \
    apk add --no-cache git curl bash

RUN adduser -D builder

ADD *.sh /home/builder/

WORKDIR /home/builder

USER root

RUN chmod 555 /home/builder/*.sh

# .git डायरेक्टरी के मालिक को builder यूजर के रूप में बदलें
RUN chown -R builder:builder /home/builder/.git

USER builder

ENTRYPOINT ["/home/builder/entrypoint.sh"]
