FROM alpine:3.18

# Install required packages
RUN apk add --no-cache curl bash iputils

WORKDIR /app

COPY update-ip.sh /app/
RUN chmod +x /app/update-ip.sh

# Create directory for persistent storage
RUN mkdir -p /app/data

CMD ["/app/update-ip.sh"]
