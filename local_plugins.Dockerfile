# WIP
FROM docker.elastic.co/logstash/logstash-oss:7.11.1
USER root
RUN yum update -y && \
    yum upgrade -y && \
    yum install rubygems git gcc-c++ patch readline readline-devel zlib zlib-devel ibffi-devel openssl-devel make bzip2 autoconf automake libtool bison sqlite-devel nano -y

ADD localbuildreqs.sh .
RUN chmod +x localbuildreqs.sh && \
    ./localbuildreqs.sh 

#we should not run bundle as root otherwise it will break for non-root users
USER logstash 


### INSTALL PLUGINS - START ####

RUN  /usr/share/logstash/vendor/jruby/bin/jruby -S gem update --system && \
    mkdir -p /usr/share/logstash/plugindir && \
    cd /usr/share/logstash/plugindir && \
    git clone https://github.com/awesome-inc/logstash-input-rss2.git && \
    cd logstash-input-rss2  && \
    /usr/share/logstash/vendor/jruby/bin/jruby -S gem build logstash-input-rss2 && \
    /usr/share/logstash/vendor/jruby/bin/jruby -S bundle config local.logstash-input-rss2 /usr/share/logstash/logstash-input-rss2 && \
    /usr/share/logstash/vendor/jruby/bin/jruby -S bundle install && \
    /usr/share/logstash/bin/logstash-plugin install logstash-input-rss2-6.2.3.gem


### INSTALL PLUGINS - END ####

### PACK PLUGINS ###
#RUN /usr/share/logstash/vendor/jruby/bin/jruby -S bundle update jar-dependencies && \
RUN    bin/logstash-plugin prepare-offline-pack --output oss_local_pluginpack.zip --overwrite logstash-input-rss2



ENTRYPOINT ["/bin/bash"]
