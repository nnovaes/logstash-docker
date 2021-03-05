# WIP
FROM docker.elastic.co/logstash/logstash-oss:7.11.1
USER root
RUN yum update -y && \
    yum upgrade -y && \
    yum install rubygems git -y
USER logstash
#RUN bin/logstash-plugin install logstash-filter-alter logstash-output-amazon_es logstash-input-okta_system_log logstash-filter-json_encode logstash-filter-tld logstash-filter-geoip logstash-filter-memcached logstash-output-exec  
#RUN bin/logstash-plugin prepare-offline-pack --output oss_pluginpack.zip --overwrite logstash-filter-alter 

### INSTALL PLUGINS - START ####

#input rss2 plugin
RUN cd /tmp && \
    git clone https://github.com/awesome-inc/logstash-input-rss2.git && \
    cd logstash-input-rss2 && \
    gem build logstash-input-rss2.gemspec && \
    /usr/share/logstash/bin/logstash-plugin install /tmp/logstash-input-rss2/logstash-input-rss2-6.2.3.gem --no-verify

### INSTALL PLUGINS - END ####

### PACK PLUGINS ###
#RUN bin/logstash-plugin prepare-offline-pack --output oss_pluginpack.zip --overwrite logstash-input-rss2


ENTRYPOINT ["/bin/bash"]
