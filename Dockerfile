FROM alpine:latest

RUN apk add --no-cache \
  git \
  curl \
  bash

WORKDIR /usr/local/bin/action

COPY entrypoint.sh .

RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
