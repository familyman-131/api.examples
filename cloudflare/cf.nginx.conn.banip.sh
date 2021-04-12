#!/bin/bash
# ban 10 most active IPs by http_x_forwarded_for in log

TAIL=$(which tail)
GREP=$(which grep)
AWK=$(which awk)
CAT=$(which cat)
CURL=$(which curl)
PRINTF=$(which printf)
#############
X_AUTH_KEY="............."
X_AUTH_EMAIL="........."
CONTENT_TYPE="application/json"
############
LOG_DIR="/home/user/bin/cf/log"
LOG="${LOG_DIR}/ng.activeip.log"
TMP_LOG="${LOG_DIR}/ng.tmp.log"
WEB_LOG="/var/log/nginx/site.access.log"
#####################
#/bin/cat /var/log/nginx/site.access.log | /usr/bin/awk '{print $7}' | /usr/bin/sort | /usr/bin/uniq -c | /usr/bin/sort -n | /usr/bin/tail -n 10

#/usr/bin/tail -n 50000 /var/log/nginx/site.access.log | /usr/bin/awk '{ print $1 }' | /usr/bin/sort | /usr/bin/uniq -c | /usr/bin/sort -nr | /usr/bin/head -n 10 | /usr/bin/awk '{print $2}' > ${LOG}
/bin/cat /var/log/nginx/site.access.log | /bin/grep " / " | /usr/bin/awk '{print $1}' | /usr/bin/sort | /usr/bin/uniq -c | /usr/bin/sort -n | /usr/bin/tail -n 10  | /usr/bin/awk '{print $2}' > ${LOG}
######################

while read IP
do
#${CAT} ${WEB_LOG} | ${GREP} "${IP}" | ${AWK} '{print $4 " " $9 " " $7}' > ${LOG_DIR}/autoban/"${IP}".log

${CURL} -sSX POST "https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules" \
     -H "X-Auth-Email: ${X_AUTH_EMAIL}" \
     -H "X-Auth-Key: ${X_AUTH_KEY}" \
     -H "Content-Type: ${CONTENT_TYPE}" \
--data "{\"mode\":\"block\",\"configuration\":{\"target\":\"ip\",\"value\":\"$IP\"},\"notes\":\"Blocked via cf_ban script\"}"
            ${PRINTF} "\n";
done < ${LOG}
