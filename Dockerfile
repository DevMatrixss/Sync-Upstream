# बेस इमेज
FROM alpine:latest

# आवश्यक डिपेंडेंसी इंस्टॉल करें
RUN apk add --no-cache \
    git \
    curl \
    bash \
    ca-certificates \
    shadow

# कस्टम (नॉन-रूट) उपयोगकर्ता जोड़ें
ARG USERNAME=customuser
ARG USER_UID=1001
ARG USER_GID=1001

RUN addgroup -g $USER_GID $USERNAME \ 
    && adduser -D -u $USER_UID -G $USERNAME $USERNAME \ 
    && mkdir -p /home/$USERNAME/.ssh \ 
    && chown -R $USERNAME:$USERNAME /home/$USERNAME

# नॉन-रूट उपयोगकर्ता में स्विच करें
USER $USERNAME

# कार्यशील डाइरेक्टरी सेट करें
WORKDIR /home/$USERNAME

# केवल entrypoint.sh स्क्रिप्ट को कॉपी करें
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# यह सुनिश्चित करें कि स्क्रिप्ट निष्पादन योग्य है
RUN chmod +x /usr/local/bin/entrypoint.sh

# एंट्रीपॉइंट सेट करें
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
