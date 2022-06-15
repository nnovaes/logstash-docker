FROM docker.io/normannovaes/logstash-docker:8x_pluginBase

FROM normannovaes/logstash:oss8x_slim_x86_64
# install plugins
COPY --from=0 /usr/share/logstash/oss_pluginpack.zip .
RUN /usr/share/logstash/bin/logstash-plugin install file:///oss_pluginpack.zip && \
    rm /oss_pluginpack.zip