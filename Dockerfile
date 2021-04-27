FROM phusion/baseimage:bionic-1.0.0

#logstash version (run 'apt-cache policy logstash' for version table, 'apt-cache policy logstash | grep Candidate' for latest)
ENV LOGSTASH_VERSION 7.12.1-1 


# trust keys
ENV ELASTIC_GPG_KEY 46095ACC8548582C1A2699A9D27D666CD88E42B4
ENV LOGSTASH_HOME /usr/share/logstash



#vars

ARG DEBIAN_FRONTEND=noninteractive

# Give children processes 60 seconds to timeout
ENV KILL_PROCESS_TIMEOUT=60
# Give all other processes (such as those which have been forked) 60 seconds to timeout
ENV KILL_ALL_PROCESSES_TIMEOUT=60

# pgp keys
RUN gpg --keyserver https://artifacts.elastic.co/GPG-KEY-elasticsearch --recv-keys ${ELASTIC_GPG_KEY} && \
    gpg -a --export ${ELASTIC_GPG_KEY} > ${ELASTIC_GPG_KEY}.asc && \
    (echo 5; echo y; echo save) | gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "$(gpg --list-packets <"$ELASTIC_GPG_KEY".asc |awk '$1=="keyid:"{print$2;exit}')" trust 


### upgrade, install prerequisites (cURL, gosu, JDK) and extras (unzip, jq, awscli)
 
RUN set -x \
&& apt-get update -qq \
&& apt-get upgrade -y \
&& apt-get install -qqy --no-install-recommends ca-certificates curl openjdk-8-jdk \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean 


# install logstash
RUN gpg -a --export 46095ACC8548582C1A2699A9D27D666CD88E42B4 |   apt-key add - && \
    apt-get install apt-transport-https && \
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list && \
    apt-get update && \
    apt-get install logstash=1:${LOGSTASH_VERSION} 

#cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 

# copy configs
COPY ./config/ /usr/share/logstash/config


# entrypoint script

ADD entrypoint.sh /opt/entrypoint.sh
RUN sed -i -e 's#^LS_HOME=$#LS_HOME='$LOGSTASH_HOME'#' /opt/entrypoint.sh \
&& chmod +x /opt/entrypoint.sh
# Override base image entrypoint and run logstash in foreground
ENTRYPOINT ["/opt/entrypoint.sh"]

