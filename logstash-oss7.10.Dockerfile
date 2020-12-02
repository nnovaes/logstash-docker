FROM phusion/baseimage:bionic-1.0.0
 
# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
 
# Upgrade the OS
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
 
# Give children processes 60 seconds to timeout
ENV KILL_PROCESS_TIMEOUT=60
# Give all other processes (such as those which have been forked) 60 seconds to timeout
ENV KILL_ALL_PROCESSES_TIMEOUT=60
 
### install prerequisites (cURL, gosu, JDK)
 
ENV GOSU_VERSION 1.12
ENV GOSU_GPG_KEY B42F6819007F00F88E364FD4036A9C25BF357DD4
 
ARG DEBIAN_FRONTEND=noninteractive
RUN set -x \
&& apt-get update -qq \
&& apt-get install -qqy --no-install-recommends ca-certificates curl \
&& rm -rf /var/lib/apt/lists/* 
RUN curl -L -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
&& curl -L -o /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
&& export GNUPGHOME="$(mktemp -d)"; \
( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GOSU_GPG_KEY" \
    || gpg --keyserver keyserver.pgp.com --recv-keys "$GOSU_GPG_KEY" ); \
gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
&& chmod +x /usr/local/bin/gosu \
&& gosu nobody true \
&& apt-get update -qq \
&& apt-get install -qqy openjdk-8-jdk \
&& apt-get clean \
&& set +x
 

### install filebeats
 
ENV LOGSTASH_VERSION 7.10.0
ENV TARBALL_SHA "b9deffe41ef051c851b6a456cebcf66cd2a17de6f49dcac8cdb29189ebbcac0ee286b9973456fa8a37bebbf7ba34295cd192f1f5c9dbbdde7da71fde126c230e"
ENV LOGSTASH_GPG_KEY "46095ACC8548582C1A2699A9D27D666CD88E42B4"
ENV LOGSTASH_HOME /usr/share/logstash
ENV DOWNLOAD_URL https://artifacts.elastic.co/downloads/logstash
ENV LOGSTASH_PACKAGE "${DOWNLOAD_URL}/logstash-oss-${LOGSTASH_VERSION}-linux-x86_64.tar.gz"
ENV LOGSTASH_TARBALL_ASC "${DOWNLOAD_URL}/logstash-oss-${VERSION}-linux-x86_64.tar.gz.asc"
ENV LOGSTASH_GID 992
ENV LOGSTASH_UID 992
 
RUN mkdir ${LOGSTASH_HOME} \
  && set -ex \
  && cd /tmp \
  && curl -L ${LOGSTASH_PACKAGE} -o logstash.tar.gz; \
  if [ "$TARBALL_SHA" ]; then \
    echo "$TARBALL_SHA *logstash.tar.gz" | sha512sum -c -; \
  fi; \
  \
  if [ "$TARBALL_ASC" ]; then \
    curl -L ${LOGSTASH_TARBALL_ASC} -o logstash.tar.gz.asc; \
    export GNUPGHOME="$(mktemp -d)"; \
    ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$LOGSTASH_GPG_KEY" \
    || gpg --keyserver pgp.mit.edu --recv-keys "$LOGSTASH_GPG_KEY" \
    || gpg --keyserver keyserver.pgp.com --recv-keys "$LOGSTASH_GPG_KEY" ); \
    gpg --batch --verify logstash.tar.gz.asc logstash.tar.gz; \
    rm -rf "$GNUPGHOME" logstash.tar.gz.asc || true; \
  fi; \
  tar xzf logstash.tar.gz -C ${LOGSTASH_HOME} --strip-components=1 \
  && groupadd -r logstash -g ${LOGSTASH_GID} \
  && useradd -r -s /usr/sbin/nologin -d ${LOGSTASH_HOME} -c "Logstash service user" -u ${LOGSTASH_UID} -g logstash logstash \
  && chown -R logstash:logstash ${LOGSTASH_HOME}
 
# Install plugins
RUN ${LOGSTASH_HOME}/bin/logstash-plugin install logstash-input-okta_system_log logstash-filter-json_encode
 
ADD entrypoint.sh /opt/entrypoint.sh
RUN sed -i -e 's#^LS_HOME=$#LS_HOME='$LOGSTASH_HOME'#' /opt/entrypoint.sh \
&& chmod +x /opt/entrypoint.sh

# since build times are huge for logstash plugins we'll separate these into layers
RUN ${LOGSTASH_HOME}/bin/logstash-plugin update
RUN ${LOGSTASH_HOME}/bin/logstash-plugin install logstash-output-amazon_es 
RUN ${LOGSTASH_HOME}/bin/logstash-plugin install logstash-filter-alter 
RUN ${LOGSTASH_HOME}/bin/logstash-plugin install logstash-input-okta_system_log 
RUN ${LOGSTASH_HOME}/bin/logstash-plugin install logstash-filter-json_encode 
RUN ${LOGSTASH_HOME}/bin/logstash-plugin install logstash-filter-tld 
RUN ${LOGSTASH_HOME}/bin/logstash-plugin install logstash-filter-geoip 
RUN ${LOGSTASH_HOME}/bin/logstash-plugin install logstash-filter-memcached 
RUN ${LOGSTASH_HOME}/bin/logstash-plugin install logstash-output-exec

# install aws cli, unzip, jq

RUN apt-get install -y unzip jq

RUN cd /tmp && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip 
    

### Clean up APT when done.
 
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
# Override base image entrypoint and run logstash in foreground
ENTRYPOINT ["/opt/entrypoint.sh"]