#!/usr/bin/env bash

NAMESPACE=$1

{
  cd secrets/ || echo "[$(date)]        ERROR:[+]No Such directory secrets";exit 1;
  echo "[$(date)]        INFO:[+]Creating secret: hive-creds"
  kubectl create -f hive-metastore-secrets.yml && cd ..
} && echo "[$(date)]        INFO:[+]Creating secret hive-creds: SUCCESS" || {
  echo "[$(date)]        ERROR:[+]Creating secret hive-creds:FAILED"
  exit 1
}

{
  cd .. &&
  echo "[$(date)]        INFO:[+]Creating pods for hive metastore and spark"
  kubectl create -f spark-with-hadoop-def.yml
} && echo "[$(date)]        INFO:[+]Creating pods for hive metastore and spark: SUCCESS" || {
  echo "[$(date)]        ERROR:[+]Creating pods for hive metastore and spark:FAILED"
  exit 1
}

sleep 30

kubectl config set-context $(kubectl config current-context) --namespace=$NAMESPACE &&
kubectl exec -it spark-with-hadoop -- bash -c "hdfs namenode -format && start-dfs.sh && hdfs dfs -mkdir -p /tmp && hdfs dfs -mkdir -p /user/hive/warehouse && hdfs dfs -chmod g+w /user/hive/warehouse" &&
kubectl exec spark-with-hadoop -- bash -c "hive --service metastore && hive --service hiveserver2"

