#!/bin/bash

VERSION="1.1.0"

# Require jq
if ! command -v jq >/dev/null 2>&1; then
    echo "$(date): ERROR: jq is required but not installed" >&2
    exit 1
fi

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
        ip=$(curl -s --max-time 10 "$service")
        if [[ $? -eq 0 && -n "$ip" ]]; then
            echo "$ip"
            return 0
        fi
    done

    echo "Failed to get public IP" >&2
    return 1
}

# Function to get DNS records (may return multiple results)
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

# Function to delete DNS record
delete_dns_record() {
    local record_id=$1

    curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$record_id" \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json"
}

# Main function to check and update DNS, ensuring only one A record remains for the name
check_and_update() {
    echo "$(date): Starting DDNS update script version $VERSION"

    # Basic env validation
    if [[ -z "$CF_TOKEN" || -z "$ZONE_ID" || -z "$DOMAIN" || -z "$SUBDOMAIN" ]]; then
        echo "$(date): ERROR: CF_TOKEN, ZONE_ID, DOMAIN and SUBDOMAIN environment variables must be set" >&2
        exit 1
    fi

    ip=$(get_public_ip)
    if [[ $? -ne 0 ]]; then
        echo "$(date): Failed to get public IP" >&2
        exit 1
    fi
    echo "$(date): Current public IP is $ip"

    dns_json=$(get_dns_record)
    if [[ -z "$dns_json" ]]; then
        echo "$(date): ERROR: Failed to query Cloudflare API" >&2
        exit 1
    fi

    # number of existing A records for this name
    results_len=$(echo "$dns_json" | jq -r '.result | length')

    if [[ "$results_len" -eq 0 ]]; then
        # No record exists -> create one
        resp=$(create_dns_record "$ip")
        ok=$(echo "$resp" | jq -r '.success')
        if [[ "$ok" == "true" ]]; then
            echo "$(date): Created new DNS record $SUBDOMAIN.$DOMAIN -> $ip"
            exit 0
        else
            echo "$(date): ERROR: Failed to create DNS record: $(echo "$resp" | jq -r '.errors[]?.message // empty')" >&2
            exit 1
        fi
    fi

    # Parse all existing records (id and content)
    # We'll:
    # 1) If any existing record already has the current public IP, keep that one.
    # 2) Otherwise update the first record to the current IP.
    # 3) Delete all other records so only a single A record remains for this name.
    mapfile -t ids < <(echo "$dns_json" | jq -r '.result[] | .id')
    mapfile -t contents < <(echo "$dns_json" | jq -r '.result[] | .content')

    keep_id=""
    # find record that already matches the current public IP
    for i in "${!ids[@]}"; do
        if [[ "${contents[$i]}" == "$ip" ]]; then
            keep_id="${ids[$i]}"
            break
        fi
    done

    if [[ -z "$keep_id" ]]; then
        # No record matched the current IP: update the first record to the current IP and keep it
        keep_id="${ids[0]}"
        echo "$(date): No matching A record found; updating record $keep_id to $ip"
        resp=$(update_dns_record "$keep_id" "$ip")
        ok=$(echo "$resp" | jq -r '.success')
        if [[ "$ok" != "true" ]]; then
            echo "$(date): ERROR: Failed to update DNS record $keep_id: $(echo "$resp" | jq -r '.errors[]?.message // empty')" >&2
            exit 1
        fi
    else
        echo "$(date): Found existing record $keep_id with current IP $ip; will remove duplicates if any"
    fi

    # Remove any other records (keep only keep_id)
    for id in "${ids[@]}"; do
        if [[ "$id" != "$keep_id" ]]; then
            echo "$(date): Deleting duplicate/old record $id"
            resp=$(delete_dns_record "$id")
            ok=$(echo "$resp" | jq -r '.success')
            if [[ "$ok" != "true" ]]; then
                echo "$(date): WARNING: Failed to delete record $id: $(echo "$resp" | jq -r '.errors[]?.message // empty')" >&2
            else
                echo "$(date): Deleted record $id"
            fi
        fi
    done

    echo "$(date): DDNS update script version $VERSION completed"
}

# Run the check and update function
check_and_update
