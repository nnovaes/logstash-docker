FROM normannovaes/logstash-docker:7.16.1_pluginBase
FROM normannovaes/logstash-docker:7.16.1_oss_slim


 # install plugins
COPY --from=0 /usr/share/logstash/oss_pluginpack.zip .
RUN /usr/share/logstash/bin/logstash-plugin install file:///oss_pluginpack.zip && \
    /usr/share/logstash/bin/logstash-plugin update && \
    /usr/share/logstash/bin/logstash-plugin list > /usr/share/logstash/config/pluginList.txt 

# copy configs
COPY ./config/ /usr/share/logstash/config


# entrypoint script

ADD entrypoint.sh /opt/entrypoint.sh
RUN sed -i -e 's#^LS_HOME=$#LS_HOME='$LOGSTASH_HOME'#' /opt/entrypoint.sh \
&& chmod +x /opt/entrypoint.sh
# Override base image entrypoint and run logstash in foreground
ENTRYPOINT ["/opt/entrypoint.sh"]

