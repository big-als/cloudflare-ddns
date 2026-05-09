# Cloudflare DDNS

A Docker-based Dynamic DNS (DDNS) updater for Cloudflare, written in PowerShell. This tool automatically updates your Cloudflare DNS records with your current public IP address at regular intervals.

## Features

- **Automatic IP Detection**: Fetches your current public IPv4 address from `https://v4.ident.me`
- **Cloudflare API Integration**: Uses Cloudflare's API to update DNS records securely
- **Flexible Scheduling**: Configurable check intervals (default: 300 seconds)
- **PowerShell Core**: Runs on PowerShell 7+ for cross-platform compatibility
- **Timezone Support**: Optional timezone configuration for logging

## Prerequisites

- Docker
- Cloudflare account with API token
- DNS zone and record configured in Cloudflare

## Quick Start

### Using Docker Compose

1. Copy `ComposeFiles/.env` and `ComposeFiles/compose.yaml` from this repository (or clone it):
   ```bash
   git clone https://github.com/big-als/cloudflare-ddns.git
   cd cloudflare-ddns
   ```

2. Copy the example env file and fill in your values:
   ```bash
   cp ComposeFiles/example.env ComposeFiles/.env
   ```
   Then edit `ComposeFiles/.env`:
   ```env
   CF_API_TOKEN=your_cloudflare_api_token
   CF_ZONE_ID=example.com
   CF_RECORD_NAME=your.subdomain.example.com
   CF_EMAIL=your_email@example.com
   CHECK_INTERVAL=300
   TZ=America/New_York
   ```

3. Run with Docker Compose:
   ```bash
   docker-compose -f ComposeFiles/compose.yaml up -d
   ```

### Using Docker Run

```bash
docker run --name cloudflare-ddns \
  -e CF_API_TOKEN=your_api_token \
  -e CF_ZONE_ID=example.com \
  -e CF_RECORD_NAME=home.example.com \
  -e CF_EMAIL=your@email.com \
  -e CHECK_INTERVAL=300 \
  -e TZ=UTC \
  alexhorst/cloudflare-ddns:alpine
```

## Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `CF_API_TOKEN` | Cloudflare API token with DNS edit permissions | Yes | - |
| `CF_ZONE_ID` | Root domain name managed in Cloudflare (e.g., `example.com`) | Yes | - |
| `CF_RECORD_NAME` | DNS record name to update (e.g., `home.example.com`) | Yes | - |
| `CF_EMAIL` | Email associated with your Cloudflare account | Yes | - |
| `CHECK_INTERVAL` | Time between IP checks in seconds | No | 300 |
| `TZ` | Timezone for logging (e.g., `America/New_York`) — see [tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | No | UTC |

> **Note:** `CF_ZONE_ID` must be the root domain name (e.g., `example.com`), not the Cloudflare zone ID hash. The script uses this value to look up the zone ID automatically via the Cloudflare API.

## Docker Image

### Alpine Linux

The optimized Alpine Linux image with PowerShell 7.6.1:

- **Published image**: `alexhorst/cloudflare-ddns:alpine`
- **Base**: Alpine 3.23 with multi-stage build

Pull the published image:
```bash
docker pull alexhorst/cloudflare-ddns:alpine
```

Or build from source:
```bash
cd "Powershell Alpine Base"
docker build -t cloudflare-ddns:alpine .
```

## API Token Setup

1. Log in to your Cloudflare account
2. Go to **My Profile** > **API Tokens**
3. Create a new token with **Edit** permissions for **DNS**
4. Copy the token value for use in `CF_API_TOKEN`

## Domain Name

The `CF_ZONE_ID` variable expects your root domain name as registered in Cloudflare (e.g., `example.com`). The script queries the Cloudflare API to resolve the zone ID automatically:

```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones?name=example.com" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json"
```

## Logging

The container logs all operations with timestamps:

```
[09/05/2026 12:00 UTC+00:00] API token validation success.
[09/05/2026 12:00 UTC+00:00] Domain zone [example.com]: ID=1234567890abcdef
[09/05/2026 12:00 UTC+00:00] DNS record [home.example.com]: Type=A, IP=192.168.1.100
[09/05/2026 12:00 UTC+00:00] Public IP Address: OLD=192.168.1.100, NEW=203.0.113.1
[09/05/2026 12:00 UTC+00:00] The current IP address does not match the DNS record IP address. Attempt to update.
[09/05/2026 12:00 UTC+00:00] DNS record update successful.
```

## Troubleshooting

### Common Issues

1. **API Token Errors**: Verify your token has DNS edit permissions
2. **Zone Not Found**: Check that `CF_ZONE_ID` is the root domain name (e.g., `example.com`), not the zone ID hash
3. **Record Not Found**: Ensure the record exists in Cloudflare
4. **Permission Denied**: The container runs as non-root (`pwshuser`)

### Debug Mode

Run an interactive shell to debug:
```bash
docker run -it --rm \
  --entrypoint /bin/sh \
  -e CF_API_TOKEN=your_token \
  -e CF_ZONE_ID=example.com \
  -e CF_RECORD_NAME=home.example.com \
  -e CF_EMAIL=your_email \
  cloudflare-ddns:alpine
```

To run a single PowerShell command:
```bash
docker run -it --rm \
  --entrypoint pwsh \
  cloudflare-ddns:alpine \
  -NoLogo -Command 'Write-Host "Debug mode"'
```

## Security Considerations

- Store API tokens securely (use Docker secrets or environment files)
- Run containers with minimal privileges
- Regularly update base images for security patches
- Monitor logs for unauthorized access attempts

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the image build and container behaviour
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Based on the original Cloudflare DDNS script by Adam the Automator.
