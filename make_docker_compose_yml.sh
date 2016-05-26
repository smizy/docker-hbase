#!/bin/bash

###
# // pseudo mode
# $ env $(grep -v ^# pseudo.env ) DEBUG=1 ./make_docker_compose_yml.sh hdfs hbase > docker-compose.yml
#
# // distributed mode
# $ env $(grep -v ^# multihost.env ) ./make_docker_compose_yml.sh hdfs hbase > docker-compose.yml
###

DEBUG=${DEBUG:-0}

# docker network default name
network_name=${network_name:-"vnet"}

# hdfs default scale size
zookeeper=${zookeeper:-3}
journalnode=${journalnode:-3}
namenode=${namenode:-2}
datanode=${datanode:-3}

# yarn default scale size
resourcemanager=${resourcemanager:-1}
historyserver=${historyserver:-1}
nodemanager=${nodemanager:-${datanode}}

# hbase default scale size
hmaster=${hmaster:-2}
regionserver=${regionserver:-${datanode}}

debug() {
  [ ${DEBUG} -gt 0 ] && echo "[DEBUG] $@" 1>&2
}
 
services=()

for component in $@; do 
    template=services.${component}.yml.tpl
    if [ ! -e ${template} ]; then
        continue
    fi
    debug "Template: $template ..."
    
    service_keys=$(cat $template | sed -e '/^## /!d' | sed -e 's/^##[ ]*//g' )

    for k in $service_keys; do
        part=$(cat $template \
            | sed -e '/^## '${k}'/,/^##\/ '${k}'/!d' \
            | sed -e '/^##/d' \
        )  
        
        KK=$(echo $k | tr '[a-z]' '[A-Z]')

        debug $k $KK
        
        scale_size=${!k}
        debug $KK scale_size: $scale_size
        
        for i in `seq 1 ${scale_size}`; do 
            swarm_filter="SWARM_FILTER_${KK}_${i}" 
            debug $swarm_filter
            # replace template variable
            filter=""
            if [ "${!swarm_filter}" != "" ]; then
                filter="- ${!swarm_filter}"            
            fi
            _part=$(echo "$part" \
                | sed -e 's/${i}/'$i'/g' \
                      -e 's/${network_name}/'$network_name'/g'  \
                | sed -e 's/${'${swarm_filter}'}/'"${filter}"'/g' \
            )
            services+=("$_part" "")
        done
    done
done

# join 
docker_compose_services="$(IFS=$'\n'; echo "${services[*]}")"

# output docker-compose.yml v2 format
cat <<EOD
version: "2"
services:

$docker_compose_services

networks:
  vnet:
    external:
      name: $network_name 
EOD

