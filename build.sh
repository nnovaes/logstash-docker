docker build -t normannovaes/logstash-docker:8.2.3_oss_slim -f oss8x_slim.Dockerfile .
docker push normannovaes/logstash-docker:8.2.3_oss_slim

docker build -t normannovaes/logstash-docker:8.2.3_pluginBase -f pluginBase.Dockerfile .
docker push normannovaes/logstash-docker:8.2.3_pluginBase
docker build -t normannovaes/logstash-docker:8.2.3_oss_plugins -f oss_plugins.Dockerfile .
docker push normannovaes/logstash-docker:8.2.3_oss_plugins
docker build -t normannovaes/logstash-docker:8.2.3_oss_full -f oss_full.Dockerfile .
docker push normannovaes/logstash-docker:8.2.3_oss_full

