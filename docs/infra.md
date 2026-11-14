# Web

## Setting up public internet tunnel for n8n
Domain : `adper.me`

cloudflare account : adper0705@gmail.com
cloudflare tunnel : 
- tunnel name: `adper-tunnel`
- Credential file (local): `/etc/cloudflared/*.json`
- origin cert: `~/.cloudflared/cert.pem`
- ingress hostname: `webhook.adper.me`
- ingress service target: `http://localhost:5678` (n8n)

DNS
- Nameserver at Namecheap -> Cloudflare nameservers
- DNS record -> `webhook.adper.me` -> CNAME created by `cloudflared tunnel route dns`

Local Service:
- n8n endpoint port: `5678`
- n8n data dir: `~/adper-n8n/n8n-data`
- Docker compose file: `~/adper-n8n/docker-compose.yml`

Systemd unit (cloudflared):
- path: `/etc/systemd/system/cloudflared.service`

Telegram:
- bot Username
    - basic hello world testing: `@adper_hello_bot`
    - created using: `@BotFather` telegram bot
