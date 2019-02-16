FROM postgres:9.3-alpine

ENV POSTGRES_DB postgres
ENV POSTGRES_USER nvisia-conf
#PASSWORD is supplied from the commandline or docker-compose

RUN addgroup -S postgres && adduser -S -G postgres postgres