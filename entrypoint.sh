#!/bin/sh

PORT="${PORT:-8080}"
PROTOCOL="${PROTOCOL:-http}"
ACA_ENABLED="${ACA_ENABLED:-true}"
ALFRESCO_ENABLED="${ALFRESCO_ENABLED:-true}"
SHARE_ENABLED="${SHARE_ENABLED:-true}"
SOLR_ENABLED="${SOLR_ENABLED:-true}"
SOLR_PROTECT="${SOLR_PROTECT:-true}"

if [[ "$PROTOCOL" == "https" ]]; then
  sed -i s%\#LISTEN%"listen *:$PORT ssl;\n\
  \      ssl_certificate     /etc/nginx/localhost.cer;\n\
  \      ssl_certificate_key /etc/nginx/localhost.key;\n\
  \      ssl_ciphers         EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH;\n\
  \      ssl_protocols       TLSv1.1 TLSv1.2;\n"%g /etc/nginx/nginx.conf
else
  sed -i s%\#LISTEN%"listen *:$PORT;"%g /etc/nginx/nginx.conf
fi

if [[ "$SOLR_PROTECT" == "true" ]]; then
  sed -i s%\#SOLR_PROTECT%"location ~ ^(/.*/service/api/solr/.*)$ {return 403;}\n\
  \      location ~ ^(/.*/s/api/solr/.*)$ {return 403;}\n\
  \      location ~ ^(/.*/wcservice/api/solr/.*)$ {return 403;}\n\
  \      location ~ ^(/.*/wcs/api/solr/.*)$ {return 403;}\n\
  \      location ~ ^(/.*/proxy/alfresco/api/solr/.*)$ {return 403 ;}\n\
  \      location ~ ^(/.*/-default-/proxy/alfresco/api/.*)$ {return 403;}\n"%g /etc/nginx/nginx.conf
fi

if [[ "$ACA_ENABLED" == "true" ]]; then
  sed -i s%\#ACA_ENDPOINT%"location / {\n\
  \        proxy_pass http://content-app:8080;\n\
  \      }"%g /etc/nginx/nginx.conf
fi

if [[ "$ALFRESCO_ENABLED" == "true" ]]; then
  sed -i s%\#ALFRESCO_ENDPOINT%"location /alfresco/ {\n\
  \        proxy_pass http://alfresco:8080;\n\
  \      }"%g /etc/nginx/nginx.conf
fi

if [[ "$SHARE_ENABLED" == "true" ]]; then
  sed -i s%\#SHARE_ENDPOINT%"location /share/ {\n\
  \        proxy_pass http://share:8080;\n\
  \      }"%g /etc/nginx/nginx.conf
fi

if [[ "$SOLR_ENABLED" == "true" ]]; then
  sed -i s%\#SOLR_ENDPOINT%'location /solr/ {\
  \        proxy_pass http://solr6:8983;\
  \        auth_basic "Solr web console";\
  \        auth_basic_user_file /etc/nginx/conf.d/nginx.htpasswd;\
  \      }'%g /etc/nginx/nginx.conf
fi

if [[ $REPO_URL ]]; then
  sed -i s%http:\/\/alfresco:8080%"$REPO_URL"%g /etc/nginx/nginx.conf
fi

if [[ $SHARE_URL ]]; then
  sed -i s%http:\/\/share:8080%"$SHARE_URL"%g /etc/nginx/nginx.conf
fi

if [[ $SOLR_URL ]]; then
  sed -i s%http:\/\/solr6:8983%"$SOLR_URL"%g /etc/nginx/nginx.conf
fi

if [[ $ACCESS_LOG ]]; then
  sed -i s%\#ENV_ACCESS_LOG%"access_log $ACCESS_LOG;"%g /etc/nginx/nginx.conf
fi

nginx -g "daemon off;"
