FROM alpine:3.7

RUN apk add curl
HEALTHCHECK CMD curl --fail http://localhost:9000/guid/ || exit 1
CMD ping 8.8.8.8