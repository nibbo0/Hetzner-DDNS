# Hetzner DDNS IPv6 Updater

A simple bash script to automatically update DNS records on Hetzner via their API when your public IPv6 address changes.

## Requirements

- `curl`
- `jq`
- A Hetzner Cloud account with DNS access
- A public IPv6 address (2001:...)

## Setup

1. Clone the repository

git clone https://github.com/nibbo0/hetzner-ddns-ipv6
cd hetzner-ddns-ipv6

2. Make the script executable
chmod +x ddns-update.sh

3.Edit the script and fill in your credentials
TOKEN="your-hetzner-api-token"
ZONE="yourdomain.de"

4.Add your DNS record names in the script
update_record "your-subdomain"

Automate with Cronjob
crontab -e
*/5 * * * * /path/to/ddns-update.sh

Logs
tail -f ~/ddns/ddns-update.log
