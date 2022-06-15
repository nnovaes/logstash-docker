# image <VERSION>_oss_plugins
FROM docker.elastic.co/logstash/logstash-oss:8.2.3
RUN bin/logstash-plugin install \
        logstash-output-opensearch \
        logstash-input-opensearch \
        logstash-filter-alter \
        logstash-input-okta_system_log \
        logstash-filter-json_encode \
        logstash-filter-tld \
        logstash-filter-geoip \
        logstash-filter-memcached \
        logstash-output-exec  
RUN bin/logstash-plugin prepare-offline-pack --output oss_pluginpack.zip --overwrite \
    logstash-output-opensearch \
    logstash-input-opensearch \
    logstash-filter-alter \
    logstash-input-okta_system_log \
    logstash-filter-json_encode \
    logstash-filter-tld \
    logstash-filter-geoip \
    logstash-filter-memcached \
    logstash-output-exec  


ENTRYPOINT ["/bin/bash"]
