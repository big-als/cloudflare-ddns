#!/bin/sh
set -e

# Defaults
: "${CHECK_INTERVAL:=300}"

echo "Starting Cloudflare DDNS container..."
echo "Interval: ${CHECK_INTERVAL}s"

# Basic validation
for var in CF_API_TOKEN CF_ZONE_ID CF_RECORD_NAME CF_EMAIL; do
  eval "val=\$$var"
  if [ -z "$val" ]; then
    echo "ERROR: Missing required environment variable: $var"
    exit 1
  fi
done

while true; do
  echo "Running DDNS update at $(date)"

  pwsh /app/cloudflare-ddns.ps1 -Email ${CF_EMAIL} -Record ${CF_RECORD_NAME} -Domain ${CF_ZONE_ID} -Token ${CF_API_TOKEN}

  echo "Sleeping for ${CHECK_INTERVAL}s..."
  sleep "$CHECK_INTERVAL"
done