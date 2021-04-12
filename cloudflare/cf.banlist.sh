#!/bin/bash
#get banned ips from CF and save them to file for unban

LOG_DIR="/home/user/bin/cf/log"
LOG="${LOG_DIR}/bannedip.log"
WEB_LOG="/var/log/nginx/site.access.log"

X_AUTH_KEY="............."
X_AUTH_EMAIL="........."
CONTENT_TYPE="application/json"

curl -X GET "https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules?&notes=Blocked via cf_ban scriptpage=1&per_page=50&match=all" \
     -H "X-Auth-Email: ${X_AUTH_EMAIL}" \
     -H "X-Auth-Key: ${X_AUTH_KEY}" \
     -H "Content-Type: ${CONTENT_TYPE}"  | jq -r '.result | map({(.id):.value}) | add ' |  sed "s/.*\"\(.*\)\".*/\1/g" | tail -n +2 | head -n -1 > ${LOG}
