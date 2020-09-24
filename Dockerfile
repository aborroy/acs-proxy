FROM nginx:stable-alpine
LABEL version="1.0.0"
LABEL maintainer="Angel Borroy <angel.borroy@alfresco.com>"

COPY nginx.conf /etc/nginx/nginx.conf

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
