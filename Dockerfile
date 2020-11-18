FROM alpine:3.12

ENV POSTGRESQL_OLD 13.0
ENV POSTGRESQL_OLD_HOME /usr/local/postgresql/${POSTGRESQL_OLD}
ENV POSTGRESQL_OLD_BIN ${POSTGRESQL_OLD_HOME}/bin

ENV POSTGRESQL_NEW 13.1
ENV POSTGRESQL_NEW_HOME /usr/local/postgresql/${POSTGRESQL_NEW}
ENV POSTGRESQL_NEW_BIN ${POSTGRESQL_NEW_HOME}/bin

ENV PGBINOLD ${POSTGRESQL_OLD_BIN}
ENV PGBINNEW ${POSTGRESQL_NEW_BIN}

ENV PGHOME /var/lib/postgresql
ENV PGDATAOLD ${PGHOME}/old_data
ENV PGDATANEW ${PGHOME}/new_data

VOLUME [ ${PGDATAOLD} ]
VOLUME [ ${PGDATANEW} ]

# 70 is the standard uid/gid for "postgres" in Alpine
RUN \
addgroup -g 70 -S postgres; \
adduser -u 70 -S -D -G postgres -H -h ${PGHOME} -s /bin/sh postgres; \
mkdir -p ${PGHOME}; \
chown -R postgres:postgres ${PGHOME}

WORKDIR /usr/local/src

RUN \
# apk add compile dep
apk add --no-cache --virtual .build-deps g++ llvm10-dev clang icu-dev perl-dev python3-dev readline-dev zlib-dev krb5-dev openssl-dev linux-pam-dev libxml2-dev libxslt-dev openldap-dev tcl-dev make linux-headers tzdata execline curl \
# download old and new versoin
&& curl -LO https://ftp.postgresql.org/pub/source/v${POSTGRESQL_OLD}/postgresql-${POSTGRESQL_OLD}.tar.gz -LO https://ftp.postgresql.org/pub/source/v${POSTGRESQL_NEW}/postgresql-${POSTGRESQL_NEW}.tar.gz \
# tar
&& tar -xf postgresql-${POSTGRESQL_OLD}.tar.gz && tar -xf postgresql-${POSTGRESQL_NEW}.tar.gz \
# make old
&& cd /usr/local/src/postgresql-${POSTGRESQL_OLD} \
&& ./configure --prefix=${POSTGRESQL_OLD_HOME}} --with-llvm --with-icu --with-tcl --with-perl --with-python --with-gssapi --with-pam --with-ldap --with-openssl --with-libedit-preferred --with-uuid=e2fs --with-libxml --with-libxslt --with-system-tzdata=/usr/share/zoneinfo --with-gnu-ld \
&& make install \
# make new
&& cd /usr/local/src/postgresql-${POSTGRESQL_NEW} \
&& ./configure --prefix=${POSTGRESQL_NEW_HOME} --with-llvm --with-icu --with-tcl --with-perl --with-python --with-gssapi --with-pam --with-ldap --with-openssl --with-libedit-preferred --with-uuid=e2fs --with-libxml --with-libxslt --with-system-tzdata=/usr/share/zoneinfo --with-gnu-ld \
&& make install \
# clean source code
&& cd /usr/local/src/ \
&& rm -rf postgresql-${POSTGRESQL_OLD}.tar.gz postgresql-${POSTGRESQL_NEW}.tar.gz /usr/local/src/postgresql-${POSTGRESQL_OLD} /usr/local/src/postgresql-${POSTGRESQL_NEW} \
# apk add run dep
&& runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
        | tr ',' '\n' \
        | sort -u \
        | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
)" \
&& apk add --no-cache --virtual .postgresql-rundeps $runDeps bash su-exec musl-locales tzdata \
&& apk del --no-network .build-deps;

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

WORKDIR /var/lib/postgresql
