FROM alpine:3.12

ENV POSTGRESQL_OLD 12.2
ENV POSTGRESQL_OLD_HOME /usr/local/postgresql/${POSTGRESQL_OLD}
ENV POSTGRESQL_OLD_BIN ${POSTGRESQL_OLD_HOME}/bin

ENV POSTGRESQL_NEW 13.0
ENV POSTGRESQL_NEW_HOME /usr/local/postgresql/${POSTGRESQL_NEW}
ENV POSTGRESQL_NEW_BIN ${POSTGRESQL_NEW_HOME}/bin

# 70 is the standard uid/gid for "postgres" in Alpine
RUN \
addgroup -g 70 -S postgres; \
adduser -u 70 -S -D -G postgres -H -h /var/lib/postgresql -s /bin/sh postgres; \
mkdir -p /var/lib/postgresql; \
chown -R postgres:postgres /var/lib/postgresql

WORKDIR /usr/local/src

RUN \
apk add --no-cache curl \
# download old versoin
&& curl -LO https://ftp.postgresql.org/pub/source/v${POSTGRESQL_OLD}/postgresql-${POSTGRESQL_OLD}.tar.gz \
# download new version
&& curl -LO https://ftp.postgresql.org/pub/source/v${POSTGRESQL_NEW}/postgresql-${POSTGRESQL_NEW}.tar.gz \
# tar
&& tar -xf postgresql-${POSTGRESQL_OLD}.tar.gz && tar -xf postgresql-${POSTGRESQL_NEW}.tar.gz \
# delete tar
&& rm postgresql-${POSTGRESQL_OLD}.tar.gz postgresql-${POSTGRESQL_NEW}.tar.gz \
# apk add
&& apk add --no-cache --virtual .build-deps g++ llvm10-dev clang icu-dev perl-dev python3-dev readline-dev zlib-dev krb5-dev openssl-dev linux-pam-dev libxml2-dev libxslt-dev openldap-dev tcl-dev make linux-headers tzdata execline \
# make old
&& cd /usr/local/src/postgresql-${POSTGRESQL_OLD} \
&& ./configure --prefix=/usr/local/postgresql/${POSTGRESQL_OLD} --with-llvm --with-icu --with-tcl --with-perl --with-python --with-gssapi --with-pam --with-ldap --with-openssl --with-libedit-preferred --with-uuid=e2fs --with-libxml --with-libxslt --with-system-tzdata=/usr/share/zoneinfo --with-gnu-ld \
&& make -j install \
# make new
&& cd /usr/local/src/postgresql-${POSTGRESQL_OLD} \
&& ./configure --prefix=/usr/local/postgresql/${POSTGRESQL_NEW} --with-llvm --with-icu --with-tcl --with-perl --with-python --with-gssapi --with-pam --with-ldap --with-openssl --with-libedit-preferred --with-uuid=e2fs --with-libxml --with-libxslt --with-system-tzdata=/usr/share/zoneinfo --with-gnu-ld \
&& make -j install \
# make source
&& rm -rf /usr/local/src/${POSTGRESQL_OLD} /usr/local/src/${POSTGRESQL_NEW}


WORKDIR /var/lib/postgresql
