version: "2"

services:

## drillbit
  drillbit-${i}:
    container_name: drillbit-${i}
    networks: ["${network_name}"]
    hostname: drillbit-${i}.${network_name}
    image: smizy/apache-drill:1.7-alpine
    ports: 
      - 8047
    environment:
      - SERVICE_8047_NAME=drillbit
      - DRILL_HEAP=512M 
      - DRILL_MAX_DIRECT_MEMEORY=1G
      - DRILL_ZOOKEEPER_QUORUM=${ZOOKEEPER_QUORUM} 
      ${SWARM_FILTER_DRILLBIT_${i}}
##/ drillbit