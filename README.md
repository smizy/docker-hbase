# docker-hbase

hbase docker image

## pseudo setup
```
# load default env
eval $(docker-machine env default)

# network 
docker network create vnet

# make docker-compose.yml 
./make_docker_compose_yml.sh hdfs hbase > docker-compose.yml

# or with datanode size 5(default 3)  
datanode=5 ./make_docker_compose_yml.sh hdfs hbase > docker-compose.yml

# hadoop+hbase startup (zookeeper, journalnode, namenode, datanode, hmaster, regionserver)
docker-compose up -d

# tail logs for a while
docker-compose logs -f

# check ps
docker-compose ps

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

# hadoop/hbase shutdown  
docker-compose stop

# cleanup container
docker-compose rm 
```