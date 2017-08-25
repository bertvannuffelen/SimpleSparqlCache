#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

remote_ip=""
remote_path="sparql"
nginx_url="${remote_ip}:443/${remote_path}"
virtuoso_url="${remote_ip}:8890/${remote_path}"


echo -e "${RED}REMOTE NGINX PROXY: ${GREEN} ${nginx_url}${NC}"
echo -e "${RED}REMOTE VIRTUOSO PROXY: ${GREEN} ${virtuoso_url}${NC}"


while IFS=  read -r query
do
    echo -e "${PURPLE}Query: ${YELLOW}${query} to Nginx${NC}" 
    nginx_start=$(date +%s)
    for i in {1..10}
    do
        curl -s -w '\n' -XPOST -H 'Content-Type: application/x-www-form-urlencoded' --data-urlencode query="$query" $nginx_url > /dev/null
    done
    nginx_stop=$(date +%s)   
    nginxavg=$(echo "scale=4; ($nginx_stop - $nginx_start) / 10" | bc -l)
    
    echo -e "${PURPLE}Query: ${YELLOW}${query} to Virtuoso${NC}"
    virtuoso_start=$(date +%s)
    for i in {1..10}
    do
        curl -s -w '\n' -XPOST -H 'Content-Type: application/x-www-form-urlencoded' --data-urlencode query="$query" $virtuoso_url > /dev/null
    done
    virtuoso_stop=$(date +%s)   
    virtuosoavg=$(echo "scale=4; ($virtuoso_stop - $virtuoso_start) / 10" | bc -l)

    decrease=$(echo "scale=4; $virtuosoavg - $nginxavg" | bc -l)
    perc_decrease=$(echo "scale=4; $decrease / $virtuosoavg * 100" | bc -l)   

    echo -e "\t${PURPLE}avg nginx proxy time (10 calls): ${YELLOW} ${nginxavg}${NC}"
    echo -e "\t${PURPLE}avg virtuoso time (10 calls): ${YELLOW} ${virtuosoavg}${NC}"
    echo -e "\t\t${PURPLE}nginx calls compared to virtuoso are ${YELLOW} ${perc_decrease} % faster. ${NC}"

done < "queries.txt"
