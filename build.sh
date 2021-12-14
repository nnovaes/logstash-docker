docker build -t normannovaes/logstash-docker:7.16.1_pluginBase -f pluginBase.Dockerfile .
docker push normannovaes/logstash-docker:7.16.1_pluginBase
docker build -t normannovaes/logstash-docker:7.16.1_oss_slim -f oss_slim.Dockerfile .
docker push normannovaes/logstash-docker:7.16.1_oss_slim
docker build -t normannovaes/logstash-docker:7.16.1_oss_plugins -f oss_plugins.Dockerfile .
docker push normannovaes/logstash-docker:7.16.1_oss_plugins
docker build -t normannovaes/logstash-docker:7.16.1_oss_full -f oss_full.Dockerfile .
docker push normannovaes/logstash-docker:7.16.1_oss_full

