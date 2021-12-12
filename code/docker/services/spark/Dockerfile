FROM centos:7.8.2003

ARG spark_version=2.4.7
ARG hadoop_version=2.10.1

RUN curl https://archive.apache.org/dist/spark/spark-${spark_version}/spark-${spark_version}-bin-without-hadoop.tgz -o spark.tgz && \
    tar -xf spark.tgz && \
    mv spark-${spark_version}-bin-without-hadoop /usr/bin/ && \
    mkdir /usr/bin/spark-${spark_version}-bin-without-hadoop/logs && \
    mv /usr/bin/spark-${spark_version}-bin-without-hadoop/conf/spark-env.sh.template /usr/bin/spark-${spark_version}-bin-without-hadoop/conf/spark-env.sh && \
    rm spark.tgz

ENV SPARK_HOME /usr/bin/spark-${spark_version}-bin-without-hadoop

ENV SPARK_MASTER_HOST spark-master

ENV SPARK_MASTER_PORT 7077

RUN curl https://archive.apache.org/dist/hadoop/common/hadoop-${hadoop_version}/hadoop-${hadoop_version}.tar.gz -o hadoop.tgz && \
    tar -xf hadoop.tgz && \
    mv hadoop-${hadoop_version} /usr/bin/ && \
    mkdir /usr/bin/hadoop-${hadoop_version}/logs && \
    rm hadoop.tgz
ADD bin/* bin/

ENV PATH="$PATH:/usr/bin/spark-${spark_version}-bin-without-hadoop/bin"

ENTRYPOINT ["sh","startup.sh"]
