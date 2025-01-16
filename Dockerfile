FROM alpine:latest

RUN apk update && \
    apk add --no-cache \
    git \
    curl

# Nayi directory /DevMatrixss banayein
RUN mkdir -p /DevMatrixss

# /DevMatrixss ko working directory banayein
WORKDIR /DevMatrixss

# entrypoint.sh script ko /DevMatrixss mein copy karein
COPY entrypoint.sh /DevMatrixss/entrypoint.sh

# Script ko executable banayein
RUN chmod +x /DevMatrixss/entrypoint.sh

# Container ke liye entrypoint set karein
ENTRYPOINT ["/bin/sh", "/DevMatrixss/entrypoint.sh"]
