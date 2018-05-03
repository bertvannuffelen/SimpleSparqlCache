#FROM nginx
#COPY nginx.conf /etc/nginx/nginx.conf
FROM danday74/nginx-lua

# set the config file
ADD config /config
COPY /config/nginx.conf /nginx/conf/nginx.conf

# make the cache space
RUN mkdir -p /var/cache/nginx/tag && chmod 777 /var/cache/nginx/tag

# announce the environment variables
ENV ENV_SPARQL_ENDPOINT_SERVICE_URL http://sparql-endpoint-service:8890/sparql 
ENV ENV_SERVICE_URL sparql.data.vlaanderen.be
ENV ENV_SUCCESS_REQUEST_CACHE_DURATION 60m
ENV ENV_FAILED_REQUEST_CACHE_DURATION 1m
ENV ENV_LOGTOSTREAM 0



# from the official NGINX distribution: forward the logs to the docker logs entrypoint
#RUN ln -sf /dev/stdout /nginx/logs/access.log \
#    && ln -sf /dev/stderr /nginx/logs/error.log


CMD ["/config/bin/start.sh", ""]

