FROM java:8-jre-alpine
MAINTAINER smizy

ENV HBASE_VERSION           1.1.5
ENV HBASE_HOME              /usr/local/hbase-${HBASE_VERSION}
ENV HBASE_CONF_DIR          ${HBASE_HOME}/conf
ENV HBASE_LOG_DIR           ${HBASE_HOME}/logs
ENV HBASE_TMP_DIR           /hbase
ENV HBASE_ROOT_DIR          hdfs://hadoop:8020/hbase
ENV HBASE_ZOOKEEPER_QUORUM  zookeeper-1.vnet,zookeeper-2.vnet,zookeeper-3.vnet

ENV HBASE_HMASTER1_HOSTNAME       hmaster-1
ENV HBASE_REGIONSERVER1_HOSTNAME  regionserver-1.vnet

RUN set -x \
    && apk --no-cache add \
        bash \
        su-exec \ 
    && mirror_url=$( \
        wget -q -O - http://www.apache.org/dyn/closer.cgi/hbase/ \
        | sed -n 's#.*href="\(http://ftp.[^"]*\)".*#\1#p' \
        | head -n 1 \
    ) \   
    && wget -q -O - ${mirror_url}/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
        | tar -xzf - -C /usr/local \
    ## user/dir/permmsion
    && adduser -D  -g '' -s /sbin/nologin -u 1000 docker \
    && adduser -D  -g '' -s /sbin/nologin hbase \
    && rm -rf ${HBASE_HOME}/docs
    
    
COPY bin/*  /usr/local/bin/ 
COPY etc/*  ${HBASE_CONF_DIR}/
    
WORKDIR ${HBASE_HOME}