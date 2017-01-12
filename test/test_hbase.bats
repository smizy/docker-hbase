load test_helper

@test "hbase returns the correct version" {
  run docker run --net vnet -e HBASE_ZOOKEEPER_QUORUM=zookeeper-1.vnet:2181 --volumes-from regionserver-1 smizy/hbase:${VERSION}-alpine hbase version

  echo "${output}"

  [ $status -eq 0 ]
  [ "${lines[0]}" = "HBase ${VERSION}" ]
}

@test "hbase shell returns the correct result" {
  run docker run  -i --net vnet -e HBASE_ZOOKEEPER_QUORUM=zookeeper-1.vnet:2181 --volumes-from regionserver-1 smizy/hbase:${VERSION}-alpine hbase shell <<EOD
create 'test', 'cf'
list 'test'
put 'test', 'row1', 'cf:a', 'value1'
put 'test', 'row2', 'cf:b', 'value2'
put 'test', 'row3', 'cf:c', 'value3'
scan 'test'
get 'test', 'row1'
disable 'test'
drop 'test'
EOD

  [ $status -eq 0 ]
  
  get_result="${lines[26]}"

  n=$(( ${#lines[*]} -1 ))
  for i in $(seq 0 $n); do
    echo "$i:******** ${lines[$i]}"
  done

  val="$(IFS=' '; set -- ${get_result}; echo $3)"

  echo "[val = $val]"
  [ "${val}" = "value=value1" ]
}

