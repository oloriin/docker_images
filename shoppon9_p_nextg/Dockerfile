FROM mysql:5.6

COPY create_nextg.sql /docker-entrypoint-initdb.d/

EXPOSE 3306
CMD ["mysqld"]