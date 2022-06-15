FROM alpine as downloader

ARG PLATFORM aarch64
ENV LOGSTASH_VERSION 8.2.3
ENV LOGSTASH_PLATFORM=$PLATFORM
ENV LOGSTASH_OS linux
ENV DOWNLOAD_URL https://artifacts.elastic.co/downloads/logstash
ENV TARBALL "${DOWNLOAD_URL}/logstash-oss-${LOGSTASH_VERSION}-${LOGSTASH_OS}-${LOGSTASH_PLATFORM}.tar.gz"
ENV TARBALL_ASC "${TARBALL}.asc"
ENV TARBALL_SHA "${TARBALL}.sha512"
ENV GPG_KEY 46095ACC8548582C1A2699A9D27D666CD88E42B4

RUN apk add ca-certificates gnupg openssl curl && \
    set -ex && \
    curl -o /tmp/logstash.tar.gz "$TARBALL" && \
    curl -o /tmp/logstash.tar.gz.sha512 "$TARBALL_SHA" && \
    curl -o /tmp/logstash.tar.gz.asc "$TARBALL_ASC" && \
    sed -i 's/logstash.*/logstash.tar.gz/g' /tmp/logstash.tar.gz.sha512 && \
    cd /tmp
RUN cd /tmp && cat logstash.tar.gz.sha512 | sha512sum -c -;
RUN export GNUPGHOME="$(mktemp -d)"; \
      ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
            || gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEY" \
            || gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEY" ); \
     gpg --batch --verify /tmp/logstash.tar.gz.asc /tmp/logstash.tar.gz;


FROM frolvlad/alpine-glibc

ENV LOGSTASH_VERSION 8.2.3
ENV PATH=/usr/share/logstash/bin:/sbin:$PATH \
    LS_SETTINGS_DIR=/usr/share/logstash/config \
    LANG='en_US.UTF-8' \
    LC_ALL='en_US.UTF-8'

COPY --from=downloader /tmp/logstash.tar.gz /tmp/logstash.tar.gz
RUN apk update && apk upgrade && \
    apk add su-exec libzmq libc6-compat bash openjdk11 &&\
    set -ex &&\
    tar -xzf /tmp/logstash.tar.gz -C /tmp/ &&\
    mv /tmp/logstash-$LOGSTASH_VERSION /usr/share/logstash &&\
    adduser -DH -s /sbin/nologin logstash &&\
    chown -R logstash:logstash /usr/share/logstash &&\
    rm -rf /tmp/* /var/cache/apk/* && \
    rm -rf /usr/share/logstash/jdk

ADD config/ /usr/share/logstash/config
ADD config/logstash.conf /usr/share/logstash/pipeline
ADD logstash-entrypoint.sh .
RUN dos2unix /logstash-entrypoint.sh
RUN chmod +x /*.sh

RUN /usr/share/logstash/bin/logstash-plugin update

ENV LS_JAVA_HOME /usr
EXPOSE 9600

ENTRYPOINT ["/logstash-entrypoint.sh"]
CMD ["-e", ""]
