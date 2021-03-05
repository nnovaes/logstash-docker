FROM normannovaes/logstash-docker:711_oss_plugins

FROM phusion/baseimage:bionic-1.0.0

# trust keys
ENV GPG_KEY 7BECEDE140B070B75DD10191697ED5D1F0694014
ENV GOSU_GPG_KEY B42F6819007F00F88E364FD4036A9C25BF357DD4
ENV ELASTIC_GPG_KEY 46095ACC8548582C1A2699A9D27D666CD88E42B4
ENV LOGSTASH_HOME /usr/share/logstash
ENV TARBALL_SHA "62f15ca0a0423a8c5afcd7071823d74c4c7de869d970b757b928b89b5e9c045764b404b692a2cf1b3d2548cc05c0ee7d903d7ae07d9411ca5499db146730e3c6"
ENV DOWNLOAD_URL https://artifacts.elastic.co/downloads/logstash
ENV LOGSTASH_PACKAGE "${DOWNLOAD_URL}/logstash-oss-${LOGSTASH_VERSION}-linux-x86_64.tar.gz"
ENV LOGSTASH_TARBALL_ASC "${DOWNLOAD_URL}/logstash-oss-${VERSION}-linux-x86_64.tar.gz.asc"
ENV LOGSTASH_GID 999
ENV LOGSTASH_UID 999


ADD .keys.sig .

#vars
ENV GOSU_VERSION 1.12
ARG DEBIAN_FRONTEND=noninteractive

# Give children processes 60 seconds to timeout
ENV KILL_PROCESS_TIMEOUT=60
# Give all other processes (such as those which have been forked) 60 seconds to timeout
ENV KILL_ALL_PROCESSES_TIMEOUT=60


RUN (gpg --keyserver hkps.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
    || gpg --keyserver https://keybase.io/nnovaes/pgp_keys.asc --recv-keys   "$GPG_KEY") && \
    gpg -a --export $GPG_KEY > gpg_key.asc && \
    (echo 5; echo y; echo save) | gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "$(gpg --list-packets <gpg_key.asc |awk '$1=="keyid:"{print$2;exit}')" trust && \
    gpg -o /tmp/list.keys --decrypt .keys.sig && \
    while read p; do gpg --keyserver hkps.pool.sks-keyservers.net --recv-keys "$p"; done < /tmp/list.keys && \
    while read p; do gpg --keyserver https://artifacts.elastic.co/GPG-KEY-elasticsearch --recv-keys "$p"; done < /tmp/list.keys && \
    gpg -a --export ${GOSU_GPG_KEY} > ${GOSU_GPG_KEY}.asc && \
    (echo 5; echo y; echo save) | gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "$(gpg --list-packets <"$GOSU_GPG_KEY".asc |awk '$1=="keyid:"{print$2;exit}')" trust && \
    gpg -a --export ${ELASTIC_GPG_KEY} > ${ELASTIC_GPG_KEY}.asc && \
    (echo 5; echo y; echo save) | gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "$(gpg --list-packets <"$ELASTIC_GPG_KEY".asc |awk '$1=="keyid:"{print$2;exit}')" trust 




### install prerequisites (cURL, gosu, JDK) and extras (unzip, jq, awscli)
 
RUN set -x \
&& apt-get update -qq \
&& apt-get install -qqy --no-install-recommends ca-certificates curl openjdk-8-jdk unzip jq \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean 

RUN cd /tmp && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip 

# install logstash
RUN gpg -a --export 46095ACC8548582C1A2699A9D27D666CD88E42B4 |   apt-key add - && \
    apt-get install apt-transport-https && \
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list && \
    apt-get update && \
    apt-get install logstash 

#cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
# install plugins
COPY --from=0 /usr/share/logstash/oss_pluginpack.zip .
RUN /usr/share/logstash/bin/logstash-plugin install file:///oss_pluginpack.zip

# copy configs
COPY ./config/* /etc/logstash/config
COPY ./settings/*  /etc/logstash

# entrypoint script

ADD entrypoint.sh /opt/entrypoint.sh
RUN sed -i -e 's#^LS_HOME=$#LS_HOME='$LOGSTASH_HOME'#' /opt/entrypoint.sh \
&& chmod +x /opt/entrypoint.sh
# Override base image entrypoint and run logstash in foreground
ENTRYPOINT ["/opt/entrypoint.sh"]
#ENTRYPOINT ["/bin/bash"]