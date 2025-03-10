#!/bin/bash

LOG_FILE="/var/log/noip-updates.log"
UPDATE_INTERVAL="${UPDATE_INTERVAL:-300}"  # Default: 5 minutes
LAST_IP_FILE="/app/data/last_ip.txt"

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

log "No-IP updater started (IPv6 mode)"

# Read secrets from files (Docker Secrets)
if [ -f "/run/secrets/noip_username" ] && [ -f "/run/secrets/noip_password" ] && [ -f "/run/secrets/noip_hostname" ]; then
    NOIP_USERNAME=$(cat /run/secrets/noip_username)
    NOIP_PASSWORD=$(cat /run/secrets/noip_password)
    NOIP_HOSTNAME=$(cat /run/secrets/noip_hostname)
    log "Successfully loaded secrets from Docker Secrets"
fi

# Fall back to environment variables if secrets are not available
if [ -z "$NOIP_USERNAME" ] || [ -z "$NOIP_PASSWORD" ] || [ -z "$NOIP_HOSTNAME" ]; then
    log "WARNING: Docker Secrets not found, falling back to environment variables"

    if [ -z "$NOIP_USERNAME" ] || [ -z "$NOIP_PASSWORD" ] || [ -z "$NOIP_HOSTNAME" ]; then
        log "ERROR: Missing required credentials"
        log "Please provide credentials via Docker Secrets or environment variables"
        exit 1
    fi
fi

# Create the last IP file if it doesn't exist
if [ ! -f "$LAST_IP_FILE" ]; then
    touch "$LAST_IP_FILE"
    log "Created new last IP file"
fi

while true; do
    # Get current public IPv6
    # Try multiple services in case one fails
    CURRENT_IP=$(curl -s -6 https://api6.ipify.org || curl -s -6 https://ipv6.icanhazip.com || curl -s -6 https://ifconfig.co)

    if [ -z "$CURRENT_IP" ]; then
        log "ERROR: Could not determine public IPv6 address"
        sleep 60
        continue
    fi

    log "Current public IPv6: $CURRENT_IP"

    # Read the last known IP
    LAST_IP=""
    if [ -f "$LAST_IP_FILE" ]; then
        LAST_IP=$(cat "$LAST_IP_FILE")
    fi

    # Only update No-IP if the IP has changed
    if [ "$CURRENT_IP" != "$LAST_IP" ]; then
        log "IP address has changed (Previous: ${LAST_IP:-none}, Current: $CURRENT_IP)"

        # Update the No-IP hostname with IPv6
        UPDATE_URL="https://dynupdate.no-ip.com/nic/update?hostname=$NOIP_HOSTNAME&myipv6=$CURRENT_IP"
        RESPONSE=$(curl -s -u "$NOIP_USERNAME:$NOIP_PASSWORD" "$UPDATE_URL" -A "NoIP-Updater/Docker/1.0")

        log "Update response: $RESPONSE"

        # Store the current IP as the last known IP
        echo "$CURRENT_IP" > "$LAST_IP_FILE"
        log "Saved new IP address to tracking file"
    else
        log "IP address unchanged, skipping update"
    fi

    # Sleep for the configured interval
    log "Next check in $UPDATE_INTERVAL seconds"
    sleep $UPDATE_INTERVAL
done
