FROM normannovaes/logstash-docker:7.13.2_oss_plugins

RUN set -x \
&& apt-get update -qq \
&& apt-get upgrade -y \
&& apt-get install -qqy --no-install-recommends git unzip jq gettext \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean 

RUN cd /tmp && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip 