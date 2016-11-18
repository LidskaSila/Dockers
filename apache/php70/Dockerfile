FROM ubuntu:16.04

RUN apt-get update -y \
  && apt-get install -y \
  software-properties-common

RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt-get update -y
RUN apt-get install -y \
	apache2 \
	libapache2-mod-php7.0 \
	php7.0 \	
	php7.0-curl \
	php7.0-gd \
	php7.0-mcrypt \
	php7.0-mysql \
	php7.0-redis \
	php7.0-xdebug \
	php7.0-xml

# Enable Remote xdebug
RUN echo "xdebug.remote_connect_back = 0" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini # must be disabled for remote_host to work!
RUN echo "xdebug.idekey = PHPSTORM" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_enable = 1" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_autostart = 0" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini
RUN echo "xdebug.profiler_enable = 0" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini
RUN echo "xdebug.var_display_max_depth = -1" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini
RUN echo "xdebug.var_display_max_children = -1" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini
RUN echo "xdebug.var_display_max_data = -1" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini
RUN echo "xdebug.max_nesting_level = 500" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_log = /tmp/xdebug.log" >> /etc/php/7.0/apache2/conf.d/20-xdebug.ini
RUN echo "memory_limit = 256M" >> /etc/php/7.0/apache2/conf.d/40-custom.ini

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars
ENV APACHE_LOG_DIR /var/log/apache2

# Configure apache
RUN usermod www-data --append --groups root
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP root

RUN set -ex \
	\
# generically convert lines like
#   export APACHE_RUN_USER=www-data
# into
#   : ${APACHE_RUN_USER:=www-data}
#   export APACHE_RUN_USER
# so that they can be overridden at runtime ("-e APACHE_RUN_USER=...")
	&& sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' "$APACHE_ENVVARS" \
	\
# setup directories and permissions
	&& . "$APACHE_ENVVARS" \
	&& for dir in \
		"$APACHE_LOCK_DIR" \
		"$APACHE_RUN_DIR" \
		"$APACHE_LOG_DIR" \
		/var/www/html \
	; do \
		rm -rvf "$dir" \
		&& mkdir -p "$dir" \
		&& chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$dir"; \
	done

# logs should go to stdout / stderr
RUN set -ex \
	&& . "$APACHE_ENVVARS" \
	&& ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"

# PHP files should be handled by PHP, and should be preferred over any other file type
RUN { \
		echo '<FilesMatch \.php$>'; \
		echo '\tSetHandler application/x-httpd-php'; \
		echo '</FilesMatch>'; \
		echo; \
		echo 'DirectoryIndex disabled'; \
		echo 'DirectoryIndex index.php index.html'; \
		echo; \
		echo '<Directory /var/www/>'; \
		echo '\tOptions -Indexes'; \
		echo '\tAllowOverride All'; \
		echo '</Directory>'; \
	} | tee "$APACHE_CONFDIR/conf-available/docker-php.conf" \
	&& a2enconf docker-php

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork

# Set ServerName
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf
RUN a2enconf servername

RUN a2enmod rewrite

## Install app
ADD phpinfo.php /var/www/html/index.php
ADD apache-config-local.conf /etc/apache2/sites-available/app.conf
RUN a2ensite app

EXPOSE 80 9000

WORKDIR "/var/www/app"

RUN apachectl restart
CMD ["apachectl", "-D", "FOREGROUND"]