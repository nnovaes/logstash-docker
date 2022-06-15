FROM normannovaes/logstash-docker:7.12.1_oss_plugins

RUN set -x \
&& apt-get update -qq \
&& apt-get install -qqy --no-install-recommends git unzip jq gettext \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean 
