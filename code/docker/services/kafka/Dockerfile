FROM ubuntu

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk ;

RUN mkdir -p ~/Downloads

RUN wget "https://mirrors.estointernet.in/apache/kafka/2.7.0/kafka_2.13-2.7.0.tgz" -O ~/Downloads/kafka.tgz

RUN mkdir -p ~/kafka && cd ~/kafka

RUN  tar -xvf ~/Downloads/kafka.tgz -C ~/kafka

ADD bin/startup.sh /bin/startup.sh

WORKDIR /bin/

RUN chmod 777 startup.sh

CMD ["sh","startup.sh"]
