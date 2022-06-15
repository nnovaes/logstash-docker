FROM normannovaes/logstash-docker:7.12.0_oss_pluginBase

FROM normannovaes/logstash-docker:7.12.0_oss_slim
# install plugins
COPY --from=0 /usr/share/logstash/oss_pluginpack.zip .
RUN /usr/share/logstash/bin/logstash-plugin install file:///oss_pluginpack.zip && \
    rm /oss_pluginpack.zip