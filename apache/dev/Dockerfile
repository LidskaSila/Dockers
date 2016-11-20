FROM lidskasila-apache-base:latest

RUN apt-get update -y
RUN apt-get install -y \
	openssh-server \
	php7.0-xdebug \
	supervisor

RUN rm -rf /var/lib/apt/lists/*

# Enable Remote xdebug
# xdebug.remote_connect_back must be disabled for remote_host to work!
ADD xdebug_setup.ini /etc/php/7.0/apache2/conf.d/xdebug_setup.ini
ADD xdebug_setup.ini /etc/php/7.0/cli/conf.d/xdebug_setup.ini

ENV PHP_IDE_CONFIG serverName=localhost.lidskasila.cz

# Configure apache for dev
RUN usermod www-data --append --groups root
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP root

## Install app
ADD phpinfo.php /var/www/html/index.php
ADD apache-config.conf /etc/apache2/sites-available/app.conf
RUN a2ensite app


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

RUN apachectl restart

CMD ["/usr/bin/supervisord"]
CMD ["/usr/sbin/sshd", "-D"]