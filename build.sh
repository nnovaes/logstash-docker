docker build -t normannovaes/logstash-docker:7.12.1_pluginbase -f pluginBase.Dockerfile .
docker build -t normannovaes/logstash-docker:7.12.1_oss_slim -f oss_slim.Dockerfile .
docker build -t normannovaes/logstash-docker:7.12.1_oss_plugins -f oss_plugins.Dockerfile .
docker build -t normannovaes/logstash-docker:7.12.1_oss_full -f oss_full.Dockerfile .
docker push normannovaes/logstash-docker:7.12.1_pluginbase
docker push normannovaes/logstash-docker:7.12.1_oss_slim
docker push normannovaes/logstash-docker:7.12.1_oss_plugins
docker push normannovaes/logstash-docker:7.12.1_oss_full

