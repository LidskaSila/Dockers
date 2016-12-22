FROM ubuntu:16.10

MAINTAINER Simon Podlipsky <simon@lidskasila.cz>

# Never ask for confirmations when installing Java
ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

RUN apt-get update -y \
  && apt-get install -y \
  software-properties-common

# Add oracle-jdk7 to repositories
RUN add-apt-repository ppa:webupd8team/java
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
# Update apt
RUN apt-get update
# Install oracle-jdk7
RUN apt-get -y install \
	composer \
	curl \
	git \
	oracle-java8-installer \
	php7.0 \
	php7.0-bcmath \
	php7.0-curl \
	php7.0-gd \
	php7.0-intl \
	php7.0-mbstring \
	php7.0-mcrypt \
	php7.0-mysql \
	php7.0-redis \
	php7.0-sqlite \
	php7.0-xml \
	php7.0-zip \
	redis-tools \
	unzip

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get -y install \
	nodejs

RUN apt-get remove -y \
	software-properties-common
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean all

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV JRE_HOME $JAVA_HOME/jre

RUN update-alternatives --install /usr/bin/java java ${JRE_HOME}/bin/java 1 \
     && update-alternatives --set java ${JRE_HOME}/bin/java \
     && update-alternatives --install /usr/bin/javac javac ${JRE_HOME}/../bin/javac 1 \
     && update-alternatives --set javac ${JRE_HOME}/../bin/javac

VOLUME /data/teamcity_agent/conf

ENV CONFIG_FILE /data/teamcity_agent/conf/buildAgent.properties

LABEL dockerImage.teamcity.version="latest" \
      dockerImage.teamcity.buildNumber="latest"

COPY run-agent.sh /run-agent.sh
COPY run-services.sh /run-services.sh
COPY dist/buildagent /opt/buildagent

RUN useradd -m buildagent && \
    chmod +x /run-agent.sh /run-services.sh

CMD ["/run-services.sh"]

EXPOSE 9090


