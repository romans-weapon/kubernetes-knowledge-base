#! /bin/bash

set -e
# build hive-postgres metastore image
{
  echo "[$(date)]        INFO:[+]Building image: hive-metastore"
  docker build . -t hive-metastore:latest -f postgres-metastore/Dockerfile
} && echo "[$(date)]        INFO:[+]Building image hive-metastore: SUCCESS" || {
  echo "[$(date)]        ERROR:[+]Building image for hive-metastore :FAILED"
  exit 1
}

# build hive-postgres metastore image
{
  echo "[$(date)]        INFO:[+]Building image: spark-standalone"
  docker build . -t spark-with-hive-standalone-hadoop:latest -f spark-with-hive-standalone/Dockerfile
} && echo "[$(date)]        INFO:[+]Building image spark-standalone: SUCCESS" || {
  echo "[$(date)]        ERROR:[+]Building image for spark-standalone :FAILED"
  exit 1
}

#spinning docker containers using compose
docker-compose up -d 

sleep 60
#starting hadoop
echo "Starting services"
docker exec -it spark-with-hive bash -c "hdfs namenode -format && start-dfs.sh && hdfs dfs -mkdir -p /tmp && hdfs dfs -mkdir -p /user/hive/warehouse && hdfs dfs -chmod g+w /user/hive/warehouse" &&
docker exec -d spark-with-hive bash -c "hive --service metastore && hive --service hiveserver2"
