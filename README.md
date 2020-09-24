# ACS Community Nginx Proxy

An enhanced Web Proxy container for ACS Community deployment.

## Environment variables

| Name | Default | Description |
| --- | --- | --- |
| REPO_URL | `http://alfresco:8080` | Repository URL inside network. |
| SHARE_URL | `http://share:8080` | Share URL inside network. |
| ACA_URL | `http://content-app:8080` | Alfresco Content Application URL inside network. |
| SOLR_URL | `http://solr6:8983` | SOLR URL inside network. |
| ACCESS_LOG | n/a | Set the `access_log` value. Set to `off` to switch off logging. |
| PORT | `8080` | External port number for the Web Proxy |
| PROTOCOL | `http` | External protocol for the Web Proxy: `http` or `https` |
| ACA_ENABLED | `true` | Configure Web Proxy for Alfresco Content Application in context / when `true` |
| ALFRESCO_ENABLED | `true` | Configure Web Proxy for Repository in context /alfresco when `true` |
| SHARE_ENABLED | `true` | Configure Web Proxy for Share in context /share when `true` |
| SOLR_ENABLED | `true` | Configure Web Proxy for SOLR in context /solr when `true`, protected by user/password |
| SOLR_PROTECT | `true` | Disable the access to Repository SOLR REST APIs when `true`, so they cannot be accessed using the Web Proxy |


## Examples

Development environment only with **alfresco** and **solr** services.
SOLR Web Console protected by user / password in `nginx.htpasswd` file.
Repository SOLR REST APIs open to be used from Web Proxy.

```yml
proxy:
    image: angelborroy/acs-proxy:1.0.0
    environment:
      - ACA_ENABLED=false
      - SHARE_ENABLED=false
      - SOLR_PROTECT=false
    depends_on:
        - alfresco
        - solr6
    volumes:
        - ./config/nginx.htpasswd:/etc/nginx/conf.d/nginx.htpasswd
    ports:
        - 8080:8080
    links:
        - alfresco
        - solr6
```

SSL Environment without Alfresco Content Application.

```yml
proxy:
    image: angelborroy/acs-proxy:1.0.0
    mem_limit: 128m
    environment:
      - ACA_ENABLED=false
      - PORT=443
      - PROTOCOL=https
    depends_on:
        - alfresco
    volumes:
        - ./config/nginx.htpasswd:/etc/nginx/conf.d/nginx.htpasswd
        - ./config/cert/localhost.cer:/etc/nginx/localhost.cer
        - ./config/cert/localhost.key:/etc/nginx/localhost.key
    ports:
        - 443:443
    links:
        - alfresco
        - share
        - solr6
```        
