FROM mysql:5.7

# Time-zone settings copy-pasted from Laradock
ENV TZ UTC
RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

RUN chown -R mysql:root /var/lib/mysql/

ARG DB_DUMP_FILE
COPY ${DB_DUMP_FILE} /docker-entrypoint-initdb.d/${DB_DUMP_FILE}

# Change datadir
#
# The original datadir (/var/lib/mysql) is added as a volume by the parent
# dockerfile and so it wouldn't commit into the image.
RUN mkdir /db-disk && \
	chown -R mysql:root /db-disk && \
	sed -i '/datadir\s*=/c\datadir = /db-disk' /etc/mysql/mysql.conf.d/mysqld.cnf

# Make a version of entrypoint.sh without starting the daemon
#
# I'll just copy the script and omit the last line (exec "$@") .
RUN sed '$ d' /entrypoint.sh > /dbinit.sh && \
	chmod --reference=entrypoint.sh dbinit.sh

# Initialize the database
ENV MYSQL_ALLOW_EMPTY_PASSWORD 1
ENV MYSQL_DATABASE lidskasila
RUN /dbinit.sh mysqld

# RAM-disk
COPY db-to-ram.sh /usr/bin/db-to-ram
RUN mkdir /db-ram && \
	chmod +x /usr/bin/db-to-ram

# supervisord
RUN apt-get update && \
	apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/mysql.conf

# Clean up
RUN rm /docker-entrypoint-initdb.d/${DB_DUMP_FILE} /dbinit.sh && \
	apt-get clean

COPY start.sh /start.sh
CMD ["/start.sh"]

EXPOSE 3306
