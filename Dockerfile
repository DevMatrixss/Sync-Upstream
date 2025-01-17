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

# स्क्रिप्ट को रूट उपयोगकर्ता के रूप में कॉपी करें और निष्पादन अनुमति सेट करें
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# नॉन-रूट उपयोगकर्ता में स्विच करें
USER $USERNAME

# कार्यशील डाइरेक्टरी सेट करें
WORKDIR /home/$USERNAME

# एंट्रीपॉइंट सेट करें
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
