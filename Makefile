
.PHONY: all
all: runtime

.PHONY: clean
clean:
	docker rmi -f smizy/hbase:${TAG} || :

.PHONY: runtime
runtime:
	docker build \
		--build-arg BUILD_DATE=${BUILD_DATE} \
		--build-arg VCS_REF=${VCS_REF} \
		--build-arg VERSION=${VERSION} \
		-t smizy/hbase:${TAG} .
	docker images | grep hbase

.PHONY: test
test:
	(docker network ls | grep vnet ) || docker network create vnet
	zookeeper=1 namenode=1 datanode=1 ./make_docker_compose_yml.sh hdfs hbase \
		| sed -E 's/(HADOOP|YARN)_HEAPSIZE=1000/\1_HEAPSIZE=600/g' \
		> docker-compose.ci.yml.tmp
	docker-compose -f docker-compose.ci.yml.tmp up -d 
	docker-compose ps
	docker run --net vnet -e HBASE_ZOOKEEPER_QUORUM=zookeeper-1.vnet:2181 --volumes-from regionserver-1 smizy/hbase:${VERSION}-alpine  bash -c 'for i in $$(seq 200); do nc -z regionserver-1.vnet 16020 && echo test starting && break; echo -n .; sleep 1; [ $$i -ge 200 ] && echo timeout && exit 124 ; done'

	bats test/test_*.bats

	docker-compose -f docker-compose.ci.yml.tmp stop
