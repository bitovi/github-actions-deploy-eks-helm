FROM alpine/k8s:1.24.10
    
COPY deploy.sh /usr/local/bin/deploy

RUN chmod +x /usr/local/bin/deploy ;\
    chown 555 /usr/local/bin/deploy

CMD deploy
