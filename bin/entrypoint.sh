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
    
    wait_until ${HADOOP_NAMENODE1_HOSTNAME} 8020 
        
    echo "`date` Starting hmaster-1 on `hostname`" 
    echo "`ulimit -a`" 2>&1
    
    set +e -x
    su-exec hdfs hdfs dfs -ls /tmp > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        su-exec hdfs hdfs dfs -mkdir -p /tmp
        su-exec hdfs hdfs dfs -chmod 1777 /tmp
    fi
    
    su-exec hdfs hdfs dfs -ls /user > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        su-exec hdfs hdfs dfs -mkdir -p /user/hdfs
        su-exec hdfs hdfs dfs -chmod 755 /user
    fi
    
    su-exec hdfs hdfs dfs -ls /hbase > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        su-exec hdfs hdfs dfs -mkdir -p /hbase
        su-exec hdfs hdfs dfs -chown hbase:hbase /hbase
    fi
    set -e +x
        
    exec su-exec hbase hbase master "$@" start

elif [ "$1" == "regionserver" ]; then
    shift
    
    wait_until ${HBASE_HMASTER1_HOSTNAME} 16000 
    
    echo "`date` Starting regionserver on `hostname`" 
    echo "`ulimit -a`" 2>&1
        
    exec su-exec hbase hbase regionserver "$@" start

elif [ "$1" == "hmaster-2" ]; then
    shift
    
    wait_until ${HBASE_REGIONSERVER1_HOSTNAME} 16020  
    
    echo "`date` Starting hmaster-2 on `hostname`" 
    echo "`ulimit -a`" 2>&1
        
    exec su-exec hbase hbase master --backup "$@" start

elif [ "$1" == "thrift" ]; then
    shift
    
    wait_until ${HBASE_REGIONSERVER1_HOSTNAME} 16020
    
    echo "`date` Starting thirft on `hostname`" 
    echo "`ulimit -a`" 2>&1
        
    exec su-exec hbase hbase thrift "$@" start

fi

exec "$@"