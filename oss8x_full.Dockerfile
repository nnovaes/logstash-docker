FROM normannovaes/logstash:oss8x_plugins_x86_64

RUN set -x \
&& apt-get update -qq \
&& apt-get install -qqy --no-install-recommends git unzip jq gettext \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean 
