docker build -t normannovaes/logstash-docker:7.13.4_pluginBase -f pluginBase.Dockerfile .
docker push normannovaes/logstash-docker:7.13.4_pluginBase
docker build -t normannovaes/logstash-docker:7.13.4_oss_slim -f oss_slim.Dockerfile .
docker push normannovaes/logstash-docker:7.13.4_oss_slim
docker build -t normannovaes/logstash-docker:7.13.4_oss_plugins -f oss_plugins.Dockerfile .
docker push normannovaes/logstash-docker:7.13.4_oss_plugins
docker build -t normannovaes/logstash-docker:7.13.4_oss_full -f oss_full.Dockerfile .
docker push normannovaes/logstash-docker:7.13.4_oss_full

