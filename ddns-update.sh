#!/bin/bash

# Hetzner DDNS IPv6 Updater
# https://github.com/nibbo0/hetzner-ddns-ipv6

TOKEN="your-hetzner-api-token"
ZONE="yourdomain.de"
LOG="$HOME/ddns/ddns-update.log"
IP_FILE="$HOME/ddns/last_ip.txt"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG"
}

# Get public IPv6 address (2001:...)
NEW_IP=$(ip -6 addr show scope global | grep -oP '(?<=inet6 )2001[\da-f:]+' | head -1)

if [ -z "$NEW_IP" ]; then
    log "ERROR: No public IPv6 address found!"
    exit 1
fi

log "Current IPv6: $NEW_IP"

# Read last known IP from file
if [ -f "$IP_FILE" ]; then
    LAST_IP=$(cat "$IP_FILE")
else
    LAST_IP=""
fi

log "Last saved IP: $LAST_IP"

if [ "$NEW_IP" == "$LAST_IP" ]; then
    log "IP unchanged, no update needed."
    exit 0
fi

log "Performing update: $LAST_IP -> $NEW_IP"

update_record() {
    local RR_NAME=$1
    RESPONSE=$(curl -s -X POST "https://api.hetzner.cloud/v1/zones/$ZONE/rrsets/$RR_NAME/AAAA/actions/set_records" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"records\": [{\"value\": \"$NEW_IP\"}]}")

    if echo "$RESPONSE" | jq -e '.action' > /dev/null 2>&1; then
        log "UPDATE SUCCESSFUL: $RR_NAME.$ZONE -> $NEW_IP"
        return 0
    else
        log "ERROR during update ($RR_NAME): $RESPONSE"
        return 1
    fi
}

# Add your subdomains here
update_record "your-subdomain"

if [ $? -eq 0 ]; then
    echo "$NEW_IP" > "$IP_FILE"
fi
