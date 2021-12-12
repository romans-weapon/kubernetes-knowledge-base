#start zookeeper
sh zookeeper-server-start.sh config/zookeeper.properties

#start Kafka
sh kafka-server-start.sh config/server.properties