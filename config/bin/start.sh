#!/bin/sh
echo $ENV_LOGTOSTREAM
if [ ! $ENV_LOGTOSTREAM ] ; then 
     echo "to file"
	export ENV_ACCESS_LOG="access_log /nginx/logs/scache.access.log upstreamlog;"
	export ENV_ERROR_LOG="error_log /nginx/logs/scache.error.log ;"
else
     echo "to stream"
	export ENV_ERROR_LOG=""
	export ENV_ACCESS_LOG=""
        ln -sf /dev/stdout /nginx/logs/access.log 
        ln -sf /dev/stderr /nginx/logs/error.log
fi


/config/bin/replace-env.sh /nginx/conf/nginx.conf

nginx -g daemon off



