FROM docker.elastic.co/logstash/logstash-oss:7.11.1
RUN bin/logstash-plugin install logstash-filter-alter logstash-output-amazon_es logstash-input-okta_system_log logstash-filter-json_encode logstash-filter-tld logstash-filter-geoip logstash-filter-memcached logstash-output-exec  
RUN bin/logstash-plugin prepare-offline-pack --output oss_pluginpack.zip --overwrite logstash-filter-alter 


ENTRYPOINT ["/bin/bash"]
