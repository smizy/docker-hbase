#!/bin/bash

set -eo pipefail

wait_until() {
    local hostname=${1?}
    local port=${2?}
    local retry=${3:-100}
    local sleep_secs=${4:-2}
    
    local address_up=0
    
    while [ ${retry} -gt 0 ] ; do
        echo  "Waiting until ${hostname}:${port} is up ... with retry count: ${retry}"
        if nc -z ${hostname} ${port}; then
            address_up=1
            break
        fi        
        retry=$((retry-1))
        sleep ${sleep_secs}
    done 
    
    if [ $address_up -eq 0 ]; then
        echo "GIVE UP waiting until ${hostname}:${port} is up! "
        exit 1
    fi       
}

# apply template
for template in $(ls ${HBASE_CONF_DIR}/*.mustache)
do
    conf_file=${template%.mustache}
    cat ${conf_file}.mustache | mustache.sh > ${conf_file}
done


if [ "$1" == "hmaster-1" ]; then
    shift
        
    echo "`date` Starting hmaster-1 on `hostname`" 
    echo "`ulimit -a`" 2>&1
        
    exec su-exec hbase bin/hbase master "$@" start

elif [ "$1" == "regionserver" ]; then
    shift
        
    echo "`date` Starting regionserver on `hostname`" 
    echo "`ulimit -a`" 2>&1
        
    exec su-exec hbase bin/hbase regionmaster "$@" start

elif [ "$1" == "hmaster-2" ]; then
    shift
    
    wait_until ${HBASE_REGIONSERVER1_HOSTNAME} 60020  
    
    echo "`date` Starting hmaster-2 on `hostname`" 
    echo "`ulimit -a`" 2>&1
        
    exec su-exec hbase bin/hbase master-backup "$@" start

fi

exec "$@"