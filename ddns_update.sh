#!/bin/bash

VERSION="1.0.0"

# Function to get public IP
get_public_ip() {
    IP_SERVICES=(
        "https://api.ipify.org"
        "https://ifconfig.me/ip"
        "https://icanhazip.com"
        "https://api.ip.sb/ip"
        "https://checkip.amazonaws.com"
    )

    for service in "${IP_SERVICES[@]}"; do
        ip=$(curl -s --max-time 10 $service)
        if [[ $? -eq 0 && -n "$ip" ]]; then
            echo $ip
            return 0
        fi
    done

    echo "Failed to get public IP" >&2
    return 1
}

# Function to get DNS record
get_dns_record() {
    curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$SUBDOMAIN.$DOMAIN" \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json"
}

# Function to update DNS record
update_dns_record() {
    local record_id=$1
    local ip=$2

    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$record_id" \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$SUBDOMAIN.$DOMAIN\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}"
}

# Function to create DNS record
create_dns_record() {
    local ip=$1

    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$SUBDOMAIN.$DOMAIN\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}"
}

# Main function to check and update DNS
check_and_update() {
    echo "$(date): Starting DDNS update script version $VERSION"

    ip=$(get_public_ip)
    if [[ $? -ne 0 ]]; then
        echo "$(date): Failed to get public IP" >&2
        exit 1
    fi
    echo "$(date): Current public IP is $ip"

    dns_record=$(get_dns_record)
    record_id=$(echo $dns_record | jq -r '.result[0].id')
    current_ip=$(echo $dns_record | jq -r '.result[0].content')

    if [[ "$ip" == "$current_ip" ]]; then
        echo "$(date): IP hasn't changed ($ip), skipping update"
        exit 0
    fi

    if [[ -n "$record_id" ]]; then
        update_dns_record $record_id $ip
        echo "$(date): Updated DNS record with new IP $ip"
    else
        create_dns_record $ip
        echo "$(date): Created new DNS record with IP $ip"
    fi

    echo "$(date): DDNS update script version $VERSION completed"
}

# Run the check and update function
check_and_update
