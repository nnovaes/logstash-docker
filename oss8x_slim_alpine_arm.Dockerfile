FROM frolvlad/alpine-glibc
ENV PATH=/usr/share/logstash/bin:/sbin:$PATH \
    LS_SETTINGS_DIR=/usr/share/logstash/config \
    LANG='en_US.UTF-8' \
    LC_ALL='en_US.UTF-8'
ARG LOGSTASH_VERSION 8.2.3
ARG LOGSTASH_PLATFORM aarch64
ARG LOGSTASH_OS linux
ARG DOWNLOAD_URL https://artifacts.elastic.co/downloads/logstash
ARG TARBALL "${DOWNLOAD_URL}/logstash-oss-${LOGSTASH_VERSION}-${LOGSTASH_OS}-${LOGSTASH_PLATFORM}.tar.gz"
ARG TARBALL_ASC "${DOWNLOAD_URL}.asc"

RUN apk update && apk upgrade && \
    apk add --no-cache su-exec libzmq libc6-compat bash openjdk11 &&\
    apk add --no-cache -t .build-deps ca-certificates gnupg openssl curl &&\
    set -ex &&\
    curl -o /tmp/logstash.tar.gz "$TARBALL" && \
    tar -xzf /tmp/logstash.tar.gz -C /tmp/ &&\
    mv /tmp/logstash-$LOGSTASH_VERSION /usr/share/logstash &&\
    adduser -DH -s /sbin/nologin logstash &&\
    chown -R logstash:logstash /usr/share/logstash &&\
    apk del --purge .build-deps &&\
    rm -rf /tmp/* /var/cache/apk/* && \
    rm -rf /usr/share/logstash/jdk

ADD config/ /usr/share/logstash/config
ADD config/logstash.conf /usr/share/logstash/pipeline
ADD logstash-entrypoint.sh .
RUN dos2unix /logstash-entrypoint.sh
RUN chmod +x /*.sh

ENV LS_JAVA_HOME /usr
EXPOSE 9600

ENTRYPOINT ["/logstash-entrypoint.sh"]
CMD ["-e", ""]
