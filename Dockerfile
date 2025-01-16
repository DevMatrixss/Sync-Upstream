FROM alpine:latest

# apk अपडेट करें और आवश्यक पैकेज इंस्टॉल करें
RUN apk update && \
    apk add --no-cache git curl bash

# 'builder' नामक नया उपयोगकर्ता बनाएं
RUN adduser -D builder

# शेल स्क्रिप्ट्स को builder के होम डायरेक्ट्री में जोड़ें
ADD *.sh /home/builder/

# कार्य निर्देशिका को /home/builder पर सेट करें
WORKDIR /home/builder

# रूट उपयोगकर्ता में स्विच करें ताकि परमिशन बदल सकें
USER root

# शेल स्क्रिप्ट्स को executable बनाएं
RUN chmod 555 /home/builder/*.sh

# builder उपयोगकर्ता को /home/builder और अन्य आवश्यक निर्देशिकाओं पर सभी अनुमतियाँ दें
RUN chown -R builder:builder /home/builder

# builder उपयोगकर्ता में वापस स्विच करें
USER builder

# कंटेनर के लिए एंट्रीपॉइंट सेट करें
ENTRYPOINT ["/home/builder/entrypoint.sh"]
