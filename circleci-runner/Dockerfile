FROM ubuntu:xenial
# xenial = 16.04

RUN echo "\ndeb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main\ndeb-src http://ppa.launchpad.net/ondrej/php/ubuntu xenial main\n" | tee -a /etc/apt/sources.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C \
	&& apt-get update \
	&& apt-get --assume-yes install curl \
	&& curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get --assume-yes install \
	    php7.1-redis
RUN apt-get --assume-yes install \
		composer \
		git \
		mysql-client \
		mysql-utilities
RUN apt-get --assume-yes install \
		netcat \
		nodejs \
		ocaml libelf-dev
RUN apt-get --assume-yes install \
		php-bcmath \
		php-curl \
		php-gd \
		php-intl \
		php-mbstring \
		php-mysql \
		php-xml \
		php-zip \
    && npm install -g yarn
