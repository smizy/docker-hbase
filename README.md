# docker-hbase

[![](https://images.microbadger.com/badges/image/smizy/hbase:1.2.6-alpine.svg)](http://microbadger.com/images/smizy/hbase:1.2.6-alpine "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/smizy/hbase:1.2.6-alpine.svg)](http://microbadger.com/images/smizy/hbase:1.2.6-alpine "Get your own version badge on microbadger.com")
[![CircleCI](https://circleci.com/gh/smizy/docker-hbase.svg?style=svg&circle-token=c37476ccaf10f385fa251abd7a45c7e93817db0f)](https://circleci.com/gh/smizy/docker-hbase)

Apache HBase docker image based on alpine

## Small setup
```
# load default env as needed
eval $(docker-machine env default)

# network 
docker network create vnet

# make docker-compose.yml with small size (no redudency)
zookeeper=1 namenode=1 datanode=1 ./make_docker_compose_yml.sh hdfs hbase > docker-compose.yml

# or with default size(zookeeper=3, namenode=2, journalnode=3, datanode=3, hmaster=2, regionserver=3)  
./make_docker_compose_yml.sh hdfs hbase > docker-compose.yml

# hadoop+hbase startup
docker-compose up -d

# tail logs for a while
docker-compose logs -f

# check ps
docker-compose ps

     Name                   Command               State                  Ports                
---------------------------------------------------------------------------------------------
datanode-1       entrypoint.sh datanode           Up      50010/tcp, 50020/tcp, 50075/tcp     
hmaster-1        entrypoint.sh hmaster-1          Up      16000/tcp, 0.0.0.0:32771->16010/tcp 
namenode-1       entrypoint.sh namenode-1         Up      0.0.0.0:32770->50070/tcp, 8020/tcp  
regionserver-1   entrypoint.sh regionserver       Up      16020/tcp, 16030/tcp                
zookeeper-1      entrypoint.sh -server 1 1 vnet   Up      2181/tcp, 2888/tcp, 3888/tcp

# check stats
docker ps --format {{.Names}} | xargs docker stats

# hbase shell
docker exec -it -u hbase regionserver-1 hbase shell
hbase(main):001:0> create 'test', 'cf'
hbase(main):002:0> list 'test'
hbase(main):003:0> put 'test', 'row1', 'cf:a', 'value1'
hbase(main):004:0> put 'test', 'row2', 'cf:b', 'value2'
hbase(main):005:0> put 'test', 'row3', 'cf:c', 'value3'
hbase(main):006:0> scan 'test'
hbase(main):007:0> get 'test', 'row1'
hbase(main):008:0> disable 'test'
hbase(main):009:0> drop 'test'
hbase(main):010:0> exit

# hadoop/hbase shutdown  
docker-compose stop

# cleanup container
docker-compose rm -v
```