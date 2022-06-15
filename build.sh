docker build -t normannovaes/logstash-docker:8.2.3_oss_slim -f oss8x_slim.Dockerfile .
docker push normannovaes/logstash-docker:8.2.3_oss_slim

docker build -t normannovaes/logstash-docker:8x_pluginBase -f pluginBase.Dockerfile .
docker push normannovaes/logstash-docker:8x_pluginBase

docker build -t normannovaes/logstash:oss8x_slim_x86_64 -f oss8x_plugins.Dockerfile .
docker push normannovaes/logstash:oss8x_slim_x86_64

docker build -t normannovaes/logstash-docker:8.2.3_oss_full -f oss_full.Dockerfile .
docker push normannovaes/logstash-docker:8.2.3_oss_full

