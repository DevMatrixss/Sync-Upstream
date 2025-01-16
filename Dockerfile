FROM alpine:latest

# Install necessary tools (git, curl, bash)
RUN apk update && \
    apk add --no-cache git curl bash

# Create 'builder' user
RUN adduser -D builder

# Clone the Git repository to /home/builder directory
RUN https://github.com/DevMatrixss/Sync-Upstream.git /home/builder

# Add your shell scripts
ADD *.sh /home/builder/

# Set working directory to /home/builder
WORKDIR /home/builder

# Set permissions for the scripts and directory
RUN chmod +x /home/builder/*.sh
RUN chown -R builder:builder /home/builder

# Switch to builder user
USER builder

# Set entrypoint to run the entrypoint.sh script
ENTRYPOINT ["/home/builder/entrypoint.sh"]
