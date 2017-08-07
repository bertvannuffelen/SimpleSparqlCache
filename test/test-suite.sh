#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

remote_ip=""
remote_path="sparql"
nginx_url="${remote_ip}:<nginx_port>/${remote_path}"
virtuoso_url="${remote_ip}:<virtuoso_port>/${remote_path}"


echo -e "${RED}REMOTE NGINX PROXY: ${GREEN} ${nginx_url}${NC}"
echo -e "${RED}REMOTE VIRTUOSO PROXY: ${GREEN} ${virtuoso_url}${NC}"

while read query; do
    echo -e "${PURPLE}query: ${YELLOW} ${query}${NC}" 
    nginxtime=$(TIMEFORMAT=%R; time (for i in {1..10}; do curl -s -w '\n' -XPOST -H 'Content-Type: application/x-www-form-urlencoded' --data-urlencode query='${query}' ${nginx_url} > /dev/null; sleep 0.5; done) 2>&1 1>/dev/null)
    virtuosotime=$(TIMEFORMAT=%R; time (for i in {1..10; do curl -s -w '\n' -XPOST -H 'Content-Type: application/x-www-form-urlencoded' --data-urlencode query='${query}' ${virtuoso_url} > /dev/null; sleep 0.5; done) 2>&1 1>/dev/null)

    nginxavg=$(echo "scale=4; $nginxtime / 10" | bc -l)
    virtuosoavg=$(echo "scale=4; $virtuosotime / 10" | bc -l)

    decrease=$(echo "scale=4; $virtuosoavg - $nginxavg" | bc -l)
    perc_decrease=$(echo "$decrease / $virtuosoavg * 100" | bc -l)

    echo -e "\t${PURPLE}avg nginx proxy time (15 calls): ${YELLOW} ${nginxavg}${NC}"
    echo -e "\t${PURPLE}avg virtuoso time (15 calls): ${YELLOW} ${virtuosoavg}${NC}"
    echo -e "\t\t${PURPLE}nginx calls compared to virtuoso are ${YELLOW} ${perc_decrease} % faster. ${NC}"
done < queries.txt


