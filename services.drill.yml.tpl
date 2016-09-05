version: "2"

services:

## drillbit
  drillbit-${i}:
    container_name: drillbit-${i}
    networks: ["${network_name}"]
    hostname: drillbit-${i}.${network_name}
    image: smizy/apache-drill:1.8-alpine
    ports: 
      - 8047
    depends_on: ["zookeeper-1"]  
    environment:
      - SERVICE_8047_NAME=drillbit
      - DRILL_HEAP=512M 
      - DRILL_MAX_DIRECT_MEMORY=1G   
      - DRILL_ZOOKEEPER_QUORUM=${ZOOKEEPER_QUORUM} 
      ${SWARM_FILTER_DRILLBIT_${i}}
##/ drillbit