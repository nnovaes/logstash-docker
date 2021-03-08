# Logstash-docker (WIP)

This logstash-docker image is based on phusion/baseimage and Elastic's official logstash distro. On top of it, it contains:

- jq, awscli, and unzip.
- oss plugins (see list below)
- local/unpublished plugins (see list below)

The plugins are installed [offline](https://www.elastic.co/guide/en/logstash/current/offline-plugins.html) from the logstash-docker:<version>_oss_plugins and logstash-docker:<version>_local_plugins images. The goal of doing so is to reduce the build time for installing  plugins since it can take a significant time depending on conditions of the network connection, while also making it modular, providing flexibility for others to change the plugin list to their like. 

The dockerfile for the <version>_oss_plugins image is provided on oss_plugins.Dockerfile. 

The dockerfile for the local_plugins image is provided on local_plugins.Dockerfile
