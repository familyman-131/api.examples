#!/bin/bash
# check if CPU load greater than or less than, and ban or unban IPs at CF firewall

ip="......"

cores=$(nproc)
load=$(awk '{print $3}'< /proc/loadavg)
echo | awk -v c="${cores}" -v l="${load}" '{print "relative load is " l*100/c "%"}'

usage=$(echo | awk -v c="${cores}" -v l="${load}" '{print l*100/c}' | awk -F. '{print $1}')
if [[ ${usage} -ge 1000 ]]; then
    echo "WARN - `uptime` - CPU load per 15 minutes is ${usage}% - trying to ban" >> /var/log/cpuload/cpuload.log
    curl -s --user "api:key-8...................." \
    https://api.mailgun.net/v3/site.com/messages \
    -F from=".." \
    -F to=... \
    -F to=... \
    -F to=... \
    -F subject="cpuload warning ${usage}%" \
    -F text="CPU load per 15 minutes is ${usage}%"
    ssh -p29 user@${ip} "/home/user/bin/cf/cf.sec.level.sh under_attack"
    ssh -p29 user@${ip} "/home/user/bin/cf/cf.banip.sh"
fi

load15=$(awk '{print $3}'< /proc/loadavg)
echo | awk -v c="${cores}" -v l="${load15}" '{print "relative load15 is " l*100/c "%"}'
usage=$(echo | awk -v c="${cores}" -v l="${load15}" '{print l*100/c}' | awk -F. '{print $1}')
if [[ ${usage} -lt 700 ]]; then
    CONN=$( ssh -p29 user@${ip} "sudo netstat -apn | grep nginx | grep "80 " | wc -l")
    echo "${CONN}"
        if [[ ${CONN} -ge 1000 ]]; then
        ssh -p29 user@${ip} "/home/user/bin/cf/cf.sec.level.sh under_attack"
                echo "WARN - `uptime` - nginx connections is ${CONN}% - set level to high" >> /var/log/cpuload/cpuload.log
        exit
        else
            echo "OK - `uptime` - CPU load per 15 minutes is ${usage}% and nginx connections is ${CONN}  - unban" >> /var/log/cpuload/cpuload.log
            ssh -p29 user@${ip} "/home/user/bin/cf/cf.banlist.sh"
            ssh -p29 user@${ip} "/home/user/bin/cf/cf.unban.sh"
                # to change security level every  00 minutes
                DD=$(date +%M)
                if [[ ${DD} -eq 00 ]]; then
                ssh -p29 user@${ip} "/home/user/bin/cf/cf.sec.level.sh high"
                fi
        fi
fi


