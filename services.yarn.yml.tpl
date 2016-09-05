version: "2"

services:  

## resourcemanager  
  resourcemanager-${i}:
    container_name: resourcemanager-${i}
    networks: ["${network_name}"]
    hostname: resourcemanager-${i}.${network_name}
    image: smizy/hadoop-base:2.7.3-alpine
    expose: ["8030-8033"]
    ports:  ["8088"]
    environment:
      - SERVICE_8088_NAME=resourcemanager
      - SERVICE_8030_IGNORE=true
      - SERVICE_8031_IGNORE=true
      - SERVICE_8032_IGNORE=true
      - SERVICE_8033_IGNORE=true
      - HADOOP_ZOOKEEPER_QUORUM=${ZOOKEEPER_QUORUM} 
      ${SWARM_FILTER_RESOURCEMANAGER_${i}}
    entrypoint: entrypoint.sh
    command: resourcemanager-${i}
##/ resourcemanager

## historyserver
  historyserver-${i}:
    container_name: historyserver-${i}
    networks: ["${network_name}"]
    hostname: historyserver-${i}.${network_name}
    image: smizy/hadoop-base:2.7.3-alpine
    expose: ["10020"]
    ports:  ["19888:19888"]
    environment:
      - SERVICE_19888_NAME=historyserver
      - SERVICE_10020_IGNORE=true
      - HADOOP_ZOOKEEPER_QUORUM=${ZOOKEEPER_QUORUM} 
      ${SWARM_FILTER_HISTORYSERVER_${i}}
    entrypoint: entrypoint.sh
    command: historyserver-${i}
##/ historyserver   

## nodemanager   
  nodemanager-${i}:
    container_name: nodemanager-${i}
    networks: ["${network_name}"]
    hostname: nodemanager-${i}.${network_name}
    image: smizy/hadoop-base:2.7.3-alpine
    expose: ["8040-8042"]
    environment:
      - SERVICE_8042_NAME=nodemanager
      - SERVICE_8040_IGNORE=true
      - SERVICE_8041_IGNORE=true
      - HADOOP_ZOOKEEPER_QUORUM=${ZOOKEEPER_QUORUM} 
      ${SWARM_FILTER_NODEMANAGER_${i}}
    entrypoint: entrypoint.sh
    command: nodemanager
##/ nodemanager