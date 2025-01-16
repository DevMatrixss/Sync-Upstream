FROM alpine:latest

RUN apk update && apk add --no-cache \
    git \
    curl \
    bash

RUN adduser -D builder

WORKDIR /home/builder

COPY *.sh /home/builder/

RUN chmod -R 775 /home/builder  # 'builder' यूज़र को लिखने की अनुमति देना

RUN chmod +x /home/builder/*.sh

USER builder

ENTRYPOINT ["/home/builder/entrypoint.sh"]
