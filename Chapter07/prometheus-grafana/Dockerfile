FROM nginx:alpine
EXPOSE 19090
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY docker-entrypoint.sh /usr/local/bin/
RUN apk update && apk add apache2-utils && \
    chmod ugo+rx /usr/local/bin/docker-entrypoint.sh && ln -s /usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]
