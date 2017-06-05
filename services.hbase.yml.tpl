version: "2"

services:

## hmaster
  hmaster-${i}:
    container_name: hmaster-${i}
    networks: ["${network_name}"]
    hostname: hmaster-${i}.${network_name}
    image: smizy/hbase:1.2.6-alpine
    expose: [16000]
    ports:  [16010]
    depends_on: ["zookeeper-1"]
    environment:
      - SERVICE_16000_NAME=hmaster
      - SERVICE_16010_IGNORE=true
      - HBASE_ZOOKEEPER_QUORUM=${ZOOKEEPER_QUORUM} 
      ${SWARM_FILTER_HMASTER_${i}}
    volumes_from:
      - namenode-${i}
    command: hmaster-${i}
##/ hmaster

## regionserver
  regionserver-${i}:
    container_name: regionserver-${i}
    networks: ["${network_name}"]
    hostname: regionserver-${i}.${network_name}
    image: smizy/hbase:1.2.6-alpine
    expose: [16020, 16030]
    depends_on: ["zookeeper-1"]
    environment:
      - SERVICE_16020_NAME=regionserver
      - SERVICE_16030_IGNORE=true
      - HBASE_ZOOKEEPER_QUORUM=${ZOOKEEPER_QUORUM} 
      ${SWARM_FILTER_REGIONSERVER_${i}}
    command: regionserver
##/ regionserver

## hbasethrift
  hbasethrift-${i}:
    container_name: hbasethrift-${i}
    networks: ["${network_name}"]
    hostname: hbasethift-${i}.${network_name}
    image: smizy/hbase:1.2.6-alpine
    ports: [9090]
    depends_on: ["regionserver-1"]
    environment:
      - SERVICE_9090_NAME=hbasethirft
      - HBASE_ZOOKEEPER_QUORUM=${ZOOKEEPER_QUORUM} 
      ${SWARM_FILTER_HBASETHRIFT_${i}}
    command: thrift  
##/ hbasethirft