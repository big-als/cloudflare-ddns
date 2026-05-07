#!/bin/sh
set -e

if [ -n "$TZ" ]; then

  echo "Setting timezone to $TZ"
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone

fi

# Defaults
: "${CHECK_INTERVAL:=300}"

echo "Starting Cloudflare DDNS container..."
echo "Interval: ${CHECK_INTERVAL}s"

# Basic validation
if [ -z "$CF_API_TOKEN" ] || [ -z "$CF_ZONE_ID" ] || [ -z "$CF_RECORD_NAME" ] || [ -z "$CF_EMAIL" ]; then
  echo "ERROR: Missing required environment variables"
  exit 1
fi

while true; do
  echo "Running DDNS update at $(date)"

  pwsh /app/cloudflare-ddns.ps1 -Email ${CF_EMAIL} -Record ${CF_RECORD_NAME} -Domain ${CF_ZONE_ID} -Token ${CF_API_TOKEN}

  echo "Sleeping for ${CHECK_INTERVAL}s..."
  sleep "$CHECK_INTERVAL"
done