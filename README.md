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

1. Clone this repository:
   ```bash
   git clone https://github.com/big-als/cloudflare-ddns.git
   cd cloudflare-ddns
   ```

2. Configure your environment variables in `ComposeFiles/.env`:
   ```env
   CF_API_TOKEN=your_cloudflare_api_token
   CF_ZONE_ID=your_zone_id
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
  -e CF_ZONE_ID=your_zone_id \
  -e CF_RECORD_NAME=your.record.com \
  -e CF_EMAIL=your@email.com \
  -e CHECK_INTERVAL=300 \
  -e TZ=UTC \
  cloudflare-ddns:alpine
```

## Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `CF_API_TOKEN` | Cloudflare API token with DNS edit permissions | Yes | - |
| `CF_ZONE_ID` | Cloudflare zone ID for your domain | Yes | - |
| `CF_RECORD_NAME` | DNS record name to update (e.g., `home.example.com`) | Yes | - |
| `CF_EMAIL` | Email associated with your Cloudflare account | Yes | - |
| `CHECK_INTERVAL` | Time between IP checks in seconds | No | 300 |
| `TZ` | Timezone for logging (e.g., `America/New_York`) | No | UTC |

## Docker Images

### Alpine Linux (Recommended)

The optimized Alpine Linux image with PowerShell 7.5.2:

- **Tag**: `cloudflare-ddns:alpine`
- **Size**: ~306MB
- **Base**: Alpine 3.18 with multi-stage build
- **Security**: CVE-2026-26171 patched

Build from source:
```bash
cd Powershell\ Alpine\ Base
docker build -t cloudflare-ddns:alpine .
```

### Ubuntu/Debian

The original Ubuntu-based image:

- **Tag**: `cloudflare-ddns:latest`
- **Base**: Ubuntu with PowerShell
- **Size**: Larger than Alpine variant

Build from source:
```bash
docker build -t cloudflare-ddns:latest .
```

## API Token Setup

1. Log in to your Cloudflare account
2. Go to **My Profile** > **API Tokens**
3. Create a new token with **Edit** permissions for **DNS**
4. Copy the token value for use in `CF_API_TOKEN`

## Zone ID Lookup

Find your zone ID:
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
2. **Zone Not Found**: Check your `CF_ZONE_ID` matches your domain
3. **Record Not Found**: Ensure the record exists in Cloudflare
4. **Permission Denied**: The container runs as non-root; timezone changes are logged but not applied

### Debug Mode

Run interactively to debug:
```bash
docker run -it --rm \
  -e CF_API_TOKEN=your_token \
  -e CF_ZONE_ID=your_zone \
  -e CF_RECORD_NAME=your_record \
  -e CF_EMAIL=your_email \
  cloudflare-ddns:alpine \
  pwsh -NoLogo -Command 'Write-Host "Debug mode"'
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
4. Test with both image variants
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Based on the original Cloudflare DDNS script by Adam the Automator.