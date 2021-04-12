#!/bin/bash
# looking for 10 most active IP in last 50k log lines by http_x_forwarded_for header from CF and ban them at CF firewall

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
LOG="${LOG_DIR}/activeip.log"
TMP_LOG="${LOG_DIR}/tmp.log"
WEB_LOG="/var/log/nginx/site.access.log"
#####################

#old logic - 10 most active IP in last 50k lines
/usr/bin/tail -n 50000 /var/log/nginx/site.access.log | /usr/bin/awk '{ print $1 }' | /usr/bin/sort | /usr/bin/uniq -c | /usr/bin/sort -nr | /usr/bin/head -n 10 | /usr/bin/awk '{print $2}' > ${LOG}

#new logic - detect if IP rps more than 0,4\sec which is 120\5min
#disabled due to useless
#MIN1=$(date +%H:%M: -d "1 minute ago")
#MIN2=$(date +%H:%M: -d "2 minute ago")
#MIN3=$(date +%H:%M: -d "3 minute ago")
#MIN4=$(date +%H:%M: -d "4 minute ago")
#MIN5=$(date +%H:%M: -d "5 minute ago")

#${TAIL}  -n 50000 ${WEB_LOG} | ${GREP} -E "${MIN1}|${MIN2}|${MIN3}|${MIN4}|${MIN5}" > ${TMP_LOG}
#${AWK} '{print $1}' ${TMP_LOG} | ${AWK} '{a[$0]++}END{for(i in a){if(a[i] > 120){print i}}}' >  ${LOG}
######################

while read IP
do
${CAT} ${WEB_LOG} | ${GREP} "${IP}" | ${AWK} '{print $4 " " $9 " " $7}' > ${LOG_DIR}/autoban/"${IP}".log

${CURL} -sSX POST "https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules" \
     -H "X-Auth-Email: ${X_AUTH_EMAIL}" \
     -H "X-Auth-Key: ${X_AUTH_KEY}" \
     -H "Content-Type: ${CONTENT_TYPE}" \
--data "{\"mode\":\"block\",\"configuration\":{\"target\":\"ip\",\"value\":\"$IP\"},\"notes\":\"Blocked via cf_ban script\"}"
            ${PRINTF} "\n";
done < ${LOG}
