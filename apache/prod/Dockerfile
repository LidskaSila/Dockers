FROM lidskasila-apache-base:latest

## Install app
ADD phpinfo.php /var/www/html/index.php
ADD apache-config.conf /etc/apache2/sites-available/app.conf
RUN a2ensite app

EXPOSE 80

WORKDIR "/var/www/app"

CMD ["apachectl", "-D", "FOREGROUND"]