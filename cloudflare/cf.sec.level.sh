#!/bin/bash
# change security level to passed as script argument ./cf.sec.level.sh high  ./cf.sec.level.sh under_attack etc


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
SEC_LVL=$1

echo "${SEC_LVL}"

curl -X PATCH "https://api.cloudflare.com/client/v4/zones/ZONEID_FROM_CF_OVERVIEW_PAGE/settings/security_level" \
     -H "X-Auth-Email: ${X_AUTH_EMAIL}" \
     -H "X-Auth-Key: ${X_AUTH_KEY}" \
     -H "Content-Type: ${CONTENT_TYPE}" \
     --data '{"value":"'${SEC_LVL}'"}'
