FROM alpine:latest

RUN apk update && \
    apk add --no-cache \
    git \
    curl

# /DevMatrixss नामक कार्य निर्देशिका को सेट करें (यदि यह पहले से मौजूद नहीं है, तो इसे बना देगा)
WORKDIR /DevMatrixss

# entrypoint.sh स्क्रिप्ट को /DevMatrixss में कॉपी करें
COPY entrypoint.sh /DevMatrixss/entrypoint.sh

# स्क्रिप्ट को executable बनाएं
RUN chmod +x /DevMatrixss/entrypoint.sh

# कंटेनर के लिए एंटरपॉइंट सेट करें
ENTRYPOINT ["/DevMatrixss/entrypoint.sh"]
