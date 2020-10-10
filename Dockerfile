FROM alpine:3.12

ENV POSTGRESQL_OLD 12.2
ENV POSTGRESQL_NEW 13.0

ENV POSTGRESQL_OLD_HOME /usr/local/postgresql/${POSTGRESQL_OLD}
ENV POSTGRESQL_OLD_BIN ${POSTGRESQL_OLD_HOME}/bin

ENV POSTGRESQL_NEW_HOME /usr/local/postgresql/${POSTGRESQL_NEW}
ENV POSTGRESQL_NEW_BIN ${POSTGRESQL_NEW_HOME}/bin

WORKDIR /usr/local/src

RUN apk add --no-cache curl && curl -LO https://ftp.postgresql.org/pub/source/v${POSTGRESQL_OLD}/postgresql-${POSTGRESQL_OLD}.tar.gz && curl -LO https://ftp.postgresql.org/pub/source/v${POSTGRESQL_NEW}/postgresql-${POSTGRESQL_NEW}.tar.gz
