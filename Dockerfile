FROM alpine:3.5
MAINTAINER smizy

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="Apache License 2.0" \
    org.label-schema.name="smizy/hbase" \
    org.label-schema.url="https://github.com/smizy" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/smizy/docker-hbase"

ENV HBASE_VERSION    $VERSION
ENV HBASE_HOME       /usr/local/hbase-${HBASE_VERSION}
ENV HADOOP_VERSION   2.7.3
ENV HADOOP_HOME      /usr/local/hadoop-${HADOOP_VERSION}
ENV HBASE_CONF_DIR   ${HBASE_HOME}/conf
ENV HBASE_LOG_DIR    /var/log/hbase
ENV HBASE_TMP_DIR    /hbase

ENV JAVA_HOME  /usr/lib/jvm/default-jvm
ENV PATH       $PATH:${JAVA_HOME}/bin:${HBASE_HOME}/sbin:${HBASE_HOME}/bin:${HADOOP_HOME}/bin

ENV HADOOP_NAMENODE1_HOSTNAME     namenode-1.vnet
ENV HBASE_ROOT_DIR                hdfs://${HADOOP_NAMENODE1_HOSTNAME}:8020/hbase
ENV HBASE_HMASTER1_HOSTNAME       hmaster-1.vnet
ENV HBASE_REGIONSERVER1_HOSTNAME  regionserver-1.vnet
ENV HBASE_ZOOKEEPER_QUORUM        zookeeper-1.vnet,zookeeper-2.vnet,zookeeper-3.vnet


RUN set -x \
    && apk --no-cache add \
        bash \
        openjdk8-jre \
        su-exec \ 
    && mirror_url=$( \
        wget -q -O - http://www.apache.org/dyn/closer.cgi/hbase/ \
        | sed -n 's#.*href="\(http://ftp.[^"]*\)".*#\1#p' \
        | head -n 1 \
    ) \   
    && wget -q -O - ${mirror_url}/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
        | tar -xzf - -C /usr/local \
    && ln -s /usr/local/hbase-${HBASE_VERSION} /usr/local/hbase-${HBASE_VERSION%.*} \
    ## user/dir/permmsion
    && adduser -D  -g '' -s /sbin/nologin -u 1000 docker \
    && for user in hadoop hbase; do \
         adduser -D -g '' -s /sbin/nologin ${user}; \
       done \
    && for user in root hbase docker; do \
         adduser ${user} hadoop; \
       done \       
    && mkdir -p \
        ${HBASE_TMP_DIR} \
        ${HBASE_LOG_DIR} \
    && chmod -R 755 \
        ${HBASE_TMP_DIR} \
        ${HBASE_LOG_DIR} \
    && chown -R hbase:hadoop \
        ${HBASE_TMP_DIR} \
        ${HBASE_LOG_DIR}  \      
    && rm -rf ${HBASE_HOME}/docs \
    && sed -i.bk -e 's/PermSize/MetaspaceSize/g' ${HBASE_CONF_DIR}/hbase-env.sh  

COPY etc/*  ${HBASE_CONF_DIR}/    
COPY bin/*  /usr/local/bin/ 
COPY lib/*  /usr/local/lib/
    
WORKDIR ${HBASE_HOME}

VOLUME ["${HBASE_TMP_DIR}", "${HBASE_LOG_DIR}", "${HBASE_HOME}"]

ENTRYPOINT ["entrypoint.sh"]