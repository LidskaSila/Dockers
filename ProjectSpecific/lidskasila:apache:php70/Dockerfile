FROM php:7.0-apache

# Install dependencies

RUN echo "deb http://packages.dotdeb.org jessie all" | tee -a /etc/apt/sources.list
RUN echo "deb-src http://packages.dotdeb.org jessie all" | tee -a /etc/apt/sources.list

RUN apt-get update && apt-get install -y software-properties-common wget
RUN wget http://www.dotdeb.org/dotdeb.gpg
RUN apt-key add dotdeb.gpg


#RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt-get update -y
RUN apt-get install -y php7.0 php7.0-redis php7.0-xdebug
#RUN apt-get install -y libapache2-mod-php7.0 php7.0-mcrypt php7.0-mysql

# Install app
ADD phpinfo.php /var/www/html/index.php
ADD apache-config.conf /etc/apache2/sites-available/app.conf
#ADD setupApacheRights.sh /setupApacheRights.sh
#RUN chmod -R 777 /setupApacheRights.sh

# Configure apache
RUN a2dismod php7
RUN a2enmod php7.0
RUN a2enmod rewrite
RUN a2ensite app

RUN usermod -u 1000 www-data

#ENV APACHE_RUN_USER root
#ENV APACHE_RUN_GROUP root
#ENV APACHE_RUN_USER www-data
#ENV APACHE_RUN_GROUP www-data
#ENV APACHE_LOG_DIR /var/log/apache2

#EXPOSE 80

#CMD /usr/sbin/apache2ctl start
