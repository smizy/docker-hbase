version: "2"

services:

## zookeeper
  zookeeper-${i}:
    container_name: zookeeper-${i}    
    networks: ["${network_name}"]
    hostname: zookeeper-${i}.${network_name}
    image: smizy/zookeeper:3.4-alpine
    environment:
      - SERVICE_2181_NAME=zookeeper
      - SERVICE_2888_IGNORE=true
      - SERVICE_3888_IGNORE=true
      ${SWARM_FILTER_ZOOKEEPER_${i}}
    command: -server ${i} ${scale_size} ${network_name}
##/ zookeeper