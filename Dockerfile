FROM alpine:latest

RUN apk update && \
    apk add --no-cache \
    git \
    curl

WORKDIR /DevMatrixss

COPY entrypoint.sh /DevMatrixss/entrypoint.sh

RUN chmod +x /DevMatrixss/entrypoint.sh

ENTRYPOINT ["/DevMatrixss/entrypoint.sh"]
