FROM lidskasila-apache-base:latest

## Install app
ADD phpinfo.php /var/www/html/index.php
ADD apache-config.conf /etc/apache2/sites-available/app.conf

COPY app /var/www/app

RUN chown www-data:www-data -R /var/www/app

RUN a2ensite app

EXPOSE 80

WORKDIR "/var/www/app"

CMD ["apachectl", "-D", "FOREGROUND"]