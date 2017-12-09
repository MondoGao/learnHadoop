FROM openjdk:9

WORKDIR /tmp

RUN apt-get update && apt-get install -y ssh rsync openssh-server vim runit

# Install Hadoop
RUN wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.9.0/hadoop-2.9.0.tar.gz && \
  tar -xzvf hadoop-2.9.0.tar.gz && \
  mv hadoop-2.9.0 /hadoop

# Hadoop Enviroments
ENV HADOOP_HOME=/hadoop 
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Hadoop Config
COPY hadoop_config/* $HADOOP_CONF_DIR/

# Hadoop Hdfs Format
RUN mkdir -p /data/hdfs/namenode && mkdir -p /data/hdfs/datanode && \
  hdfs namenode -format

# Runit Config
COPY ./other_config/runit_service/ /etc/service/
COPY ./other_config/runit/ /etc/runit/

# SSH Config
RUN mkdir ~/.ssh
COPY ./other_config/ssh/ /root/.ssh
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys

RUN mkdir /run/sshd

EXPOSE 8088 50070

ENTRYPOINT ["runit"]
