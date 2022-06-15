FROM alpine:latest
LABEL website="Secure Docker Images https://secureimages.dev"
LABEL description="We secure your business from scratch."
LABEL maintainer="support@secureimages.dev"


ARG TARBALL_ASC="https://artifacts.elastic.co/downloads/logstash/logstash-oss-${LOGSTASH_VERSION}-linux-x86_64.tar.gz.asc"
### https://artifacts.elastic.co/downloads/logstash/logstash-oss-7.11.1-linux-x86_64.tar.gz.sha512
#https://artifacts.elastic.co/downloads/logstash/logstash-8.2.3-linux-aarch64.tar.gz
#ARG TARBALL_SHA="62f15ca0a0423a8c5afcd7071823d74c4c7de869d970b757b928b89b5e9c045764b404b692a2cf1b3d2548cc05c0ee7d903d7ae07d9411ca5499db146730e3c6"
#ARG GPG_KEY="46095ACC8548582C1A2699A9D27D666CD88E42B4"

ENV PATH=/usr/share/logstash/bin:/sbin:$PATH \
    LS_SETTINGS_DIR=/usr/share/logstash/config \
    LANG='en_US.UTF-8' \
    LC_ALL='en_US.UTF-8'




ENV LOGSTASH_VERSION 8.2.3
ENV LOGSTASH_PLATFORM x86_64
ENV LOGSTASH_OS linux
ENV DOWNLOAD_URL https://artifacts.elastic.co/downloads/logstash
ENV TARBALL "${DOWNLOAD_URL}/logstash-oss-${LOGSTASH_VERSION}-${LOGSTASH_OS}-${LOGSTASH_PLATFORM}.tar.gz"
ENV TARBALL_ASC "${DOWNLOAD_URL}/logstash-oss-${VERSION}.tar.gz.asc"

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
EXPOSE 5044 9600

ENTRYPOINT ["/logstash-entrypoint.sh"]
CMD ["-e", ""]
