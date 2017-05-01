FROM lidskasila-apache-base:latest

RUN apt-get update -y
RUN apt-get install -y \
    apt-transport-https \
    curl \
	openssh-server \
	php7.1-sqlite3 \
	php7.1-xdebug \
	supervisor

# Install yarn and npm
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -

RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -y
RUN apt-get install -y \
    nodejs \
	yarn

RUN rm -rf /var/lib/apt/lists/*

# Enable Remote xdebug
# xdebug.remote_connect_back must be disabled for remote_host to work!
ADD xdebug_setup.ini /etc/php/7.1/apache2/conf.d/xdebug_setup.ini
ADD xdebug_setup.ini /etc/php/7.1/cli/conf.d/xdebug_setup.ini

ENV PHP_IDE_CONFIG serverName=localhost.lidskasila.cz

# Configure apache for dev
RUN usermod www-data --append --groups root
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP root

## Install app
ADD phpinfo.php /var/www/html/index.php
ADD apache-config.conf /etc/apache2/sites-available/app.conf
RUN a2ensite app

RUN echo "max_execution_time = -1" >> /etc/php/7.1/apache2/conf.d/40-custom.ini

#Setup OpenSSH and Supervisor
RUN mkdir -p /var/run/sshd /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile


EXPOSE 22 80 9000

WORKDIR "/var/www/app"

RUN apachectl start

CMD ["/usr/bin/supervisord"]
