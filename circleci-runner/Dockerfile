FROM ubuntu:xenial
# xenial = 16.04

RUN echo "\ndeb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main\ndeb-src http://ppa.launchpad.net/ondrej/php/ubuntu xenial main\n" | tee -a /etc/apt/sources.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C \
	&& apt-get update \
	&& apt-get --assume-yes install curl \
	&& curl -sL https://deb.nodesource.com/setup_6.x | bash - \
	&& apt-get --assume-yes install php7.1-redis \
	&& apt-get --assume-yes install \
		nodejs \
		git \
		composer \
		php-gd php-curl php-mysql php-mbstring \
		php-bcmath \
		php-xml \
		php-zip \
		mysql-client \
		netcat \
		ocaml libelf-dev \
		php-intl \
	&& npm install -g yarn
