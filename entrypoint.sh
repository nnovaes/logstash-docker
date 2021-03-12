#!/bin/sh
#exec /sbin/setuser logstash ${LOGSTASH_HOME}/bin/logstash >> /proc/1/fd/1 &
exec ${LOGSTASH_HOME}/bin/logstash --path.settings /usr/share/logstash/config