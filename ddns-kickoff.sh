. /etc/profile
pwsh /DDNS/cloudflare-ddns.ps1 -Email "$CLOUDFLARE_EMAIL" -Token "$CLOUDFLARE_API_TOKEN" -Domain "$CLOUDFLARE_DOMAIN" -Record "$CLOUDFLARE_DNS_RECORD"
