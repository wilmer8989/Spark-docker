FROM java:8-jdk-alpine

ENV DAEMON_RUN=true
ENV SPARK_VERSION=3.1.2
ENV HADOOP_VERSION=3.2
ENV SCALA_VERSION=2.13.4
ENV SCALA_HOME=/usr/share/scala

RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.8/main/" > /etc/apk/repositories

RUN apk update && apk upgrade

WORKDIR "/tmp" 

RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    apk add --no-cache bash curl jq && \
    cd "/tmp" && \
    wget --no-verbose "https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    apk del .build-dependencies && \
    rm -rf "/tmp/"*
    
#Scala instalation
RUN export PATH="/usr/local/sbt/bin:$PATH" &&  \
    apk update && apk add ca-certificates wget tar && \
    mkdir -p "/usr/local/sbt" && \
    wget -qO - --no-check-certificate "https://github.com/sbt/sbt/releases/download/v1.4.4/sbt-1.4.4.tgz" | tar xz -C /usr/local/sbt --strip-components=1 && \
    sbt sbtVersion -Dsbt.rootdir=true

RUN apk add --no-cache python3

RUN wget --no-verbose https://httpd-mirror.sergal.org/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
      && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark \
      && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
