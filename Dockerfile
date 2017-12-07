FROM openjdk:9

WORKDIR /tmp

RUN apt-get update && apt-get install -y ssh rsync openssh-server vim

# Install Hadoop
RUN wget -O hadoop.tar.gz http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.9.0/hadoop-2.9.0.tar.gz
RUN tar -xzvf hadoop.tar.gz -C /usr/local/
RUN mv /usr/local/hadoop-2.9.0 /usr/local/hadoop
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop

COPY other_config/ssh_config /root/.ssh/config
COPY hadoop_config/* $HADOOP_CONF_DIR/

RUN mkdir -p /data/hdfs/namenode
RUN mkdir -p /data/hdfs/datanode

RUN hdfs namenode -format

EXPOSE 8088 50070
ENTRYPOINT ["sh", "-c", "service ssh start;start-dfs.sh;start-yarn.sh;bash"]


