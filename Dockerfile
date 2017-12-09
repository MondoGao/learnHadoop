FROM openjdk:9

WORKDIR /tmp

RUN apt-get update && apt-get install -y ssh rsync openssh-server vim runit

ARG HADOOP_HOME=/hadoop
# Install Hadoop
RUN wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.9.0/hadoop-2.9.0.tar.gz && \
  tar -xzvf hadoop-2.9.0.tar.gz && \
  mv hadoop-2.9.0 $HADOOP_HOME

# Hadoop Enviroments
ENV HADOOP_HOME=$HADOOP_HOME PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop

ARG CONFIG_DIR=./configs

# Hadoop Config
COPY $CONFIG_DIR/hadoop/* $HADOOP_CONF_DIR/

# Hadoop Hdfs Format
RUN mkdir -p /data/hdfs/namenode && mkdir -p /data/hdfs/datanode && \
  hdfs namenode -format

ARG NODE_TYPE=master

# Runit Config
COPY $CONFIG_DIR/$NODE_TYPE/runit/ /etc/runit/

# SSH Config
COPY $CONFIG_DIR/ssh/ /root/.ssh
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys && \
  mkdir /run/sshd

EXPOSE 8088 50070

ENTRYPOINT ["runit"]
