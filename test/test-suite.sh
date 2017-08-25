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
    echo -e "${PURPLE}Query: ${YELLOW}${query} to Nginx" 
    nginx_start=$(date +%s)
    for i in {1..10}
    do
        curl -s -w '\n' -XPOST -H 'Content-Type: application/x-www-form-urlencoded' --data-urlencode query="$query" $nginx_url > /dev/null
    done
    nginx_stop=$(date +%s)   
    nginxavg=$(echo "scale=4; ($nginx_stop - $nginx_start) / 10" | bc -l)
    
    echo -e "Query: ${query} to Virtuoso"
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



# while read query; do
#     echo -e "${PURPLE}query: ${YELLOW} ${query}${NC}"

#     nginx_start=$(date +%s)
#     echo $nginx_start
#     curl -s -w '\n' -XPOST -H 'Content-Type: application/x-www-form-urlencoded' --data-urlencode query="${query}" ${nginx_url} > /dev/null
#     nginx_stop=$(date +%s)
#     echo $nginx_stop
#     nginxavg=$(echo "scale=4; ($nginx_stop - $nginx_start) / 3" | bc -l)

#     # nginxtime=$(TIMEFORMAT=%R; time (for i in {1..15}; do curl -s -w '\n' -XPOST -H 'Content-Type: application/x-www-form-urlencoded' --data-urlencode query='${query}' ${nginx_url} > /dev/null; sleep 0.5; done) 2>&1 1>/dev/null)
#     # virtuosotime=$(TIMEFORMAT=%R; time (for i in {1..15}; do curl -s -w '\n' -XPOST -H 'Content-Type: application/x-www-form-urlencoded' --data-urlencode query='${query}' ${virtuoso_url} > /dev/null; sleep 0.5; done) 2>&1 1>/dev/null)
#     #
#     # nginxavg=$(echo "scale=4; $nginxtime / 15" | bc -l)
#     # virtuosoavg=$(echo "scale=4; $virtuosotime / 15" | bc -l)
#     #
#     # decrease=$(echo "scale=4; $virtuosoavg - $nginxavg" | bc -l)
#     # perc_decrease=$(echo "scale=4; $decrease / $virtuosoavg * 100" | bc -l)
#     #
#     # echo -e "\t${PURPLE}avg nginx proxy time (15 calls): ${YELLOW} ${nginxavg}${NC}"
#     # echo -e "\t${PURPLE}avg virtuoso time (15 calls): ${YELLOW} ${virtuosoavg}${NC}"
#     # echo -e "\t\t${PURPLE}nginx calls compared to virtuoso are ${YELLOW} ${perc_decrease} % faster. ${NC}"

#     # select distinct ?p where {?s ?p ?o} LIMIT 5000
#     # select distinct ?p where {?s ?p ?o} LIMIT 10000
#     # select distinct ?p where {?s ?p ?o} LIMIT 25000
#     # select distinct ?p where {?s ?p ?o} LIMIT 50000
#     # select distinct ?p where {?s ?p ?o} LIMIT 100000
#     # select distinct ?p where {?s ?p ?o} LIMIT 200000
#     # select distinct ?p where {?s ?p ?o} LIMIT 500000
#     # select distinct ?p where {?s ?p ?o} LIMIT 1000000

# done < queries.txt
