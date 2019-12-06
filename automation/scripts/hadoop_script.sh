#!/bin/bash

sudo apt-get -y update

# The prompt from the update still occurs. maybe use DEBIAN_FRONTEND=noninteractive ?
sudo apt-get -y install openjdk-8-jdk-headless
mkdir /home/ubuntu/server

echo "=== Starting setup for Spark ==="
# download Spark
wget -c https://www-us.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz -O spark-2.4.4-bin-hadoop2.7.tgz
tar -xzf spark-2.4.4-bin-hadoop2.7.tgz
mv spark-2.4.4-bin-hadoop2.7/ spark
sudo mv spark/ /usr/lib/

echo "=== Configuring Spark ==="
# configure Spark
cp /usr/lib/spark/conf/spark-env.sh.template /usr/lib/spark/conf/spark-env.sh 

cat >> /usr/lib/spark/conf/spark-env.sh << EOF
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
SPARK_WORKER_MEMORY=4g
PYSPARK_PYTHON=python3
./bin/pyspark
EOF
chmod a+rwx /usr/lib/spark/conf/spark-env.sh

echo "=== Downloading hadoop==="
wget -O /home/ubuntu/server/hadoop-2.8.5.tar.gz http://apache.mirrors.tds.net/hadoop/common/hadoop-2.8.5/hadoop-2.8.5.tar.gz
tar xvzf /home/ubuntu/server/hadoop-2.8.5.tar.gz -C /home/ubuntu/server

echo "=== Hadoop set up ==="
# this line edits the hadoop-env.sh and replace the JAVA_HOME line
sed -i '25s/.*/export JAVA_HOME\=\/usr\/lib\/jvm\/java-8-openjdk-amd64/' /home/ubuntu/server/hadoop-2.8.5/etc/hadoop/hadoop-env.sh
rm /home/ubuntu/server/hadoop-2.8.5/etc/hadoop/core-site.xml
cat >> /home/ubuntu/server/hadoop-2.8.5/etc/hadoop/core-site.xml << EOF 
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value><nnode>:9000</value>
  </property>
</configuration>
EOF

sudo mkdir -p /usr/local/hadoop/hdfs/data
sudo chown -R ubuntu:ubuntu /usr/local/hadoop/hdfs/data

# echo "=== Starting setup for Spark ==="
# # download Spark
# wget -q -c https://www-us.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz -O spark-2.4.4-bin-hadoop2.7.tgz
# tar -xzf spark-2.4.4-bin-hadoop2.7.tgz
# mv spark-2.4.4-bin-hadoop2.7/ spark
# sudo mv spark/ /usr/lib/

# echo "=== Configuring Spark ==="
# # configure Spark
# cp /usr/lib/spark/conf/spark-env.sh.template /usr/lib/spark/conf/spark-env.sh 

# cat >> /usr/lib/spark/conf/spark-env.sh << EOF
# JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
# SPARK_WORKER_MEMORY=4g
# PYSPARK_PYTHON=python3
# ./bin/pyspark
# EOF

sudo apt-get install -y python3-pip
pip3 install pyspark --no-cache-dir
pip3 install pymongo --no-cache-dir

# install sbt
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get -y install sbt

echo "=== Set env and PATH ==="

echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/profile
echo "export SBT_HOME=/usr/share/sbt-launcher-packaging/bin/sbt-launch.jar" >> /etc/profile
echo "export SPARK_HOME=/usr/lib/spark" >> /etc/profile
echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
echo "export PATH=$PATH:$SBT_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin" >> /etc/profile

echo "=== Completed Spark Setup ==="