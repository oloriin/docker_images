# Version: 0.0.1 MySql 5.6 для тестирования
FROM debian:jessie
MAINTAINER GapArchi <peh626@gmail.com>

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN mkdir /docker-entrypoint-initdb.d

RUN apt-get update \
        && apt-get install -y perl pwgen --no-install-recommends \
        && apt-get install -y --force-yes vim \
        && rm -rf /var/lib/apt/lists/* \
        && apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5 \
        && echo "deb http://repo.mysql.com/apt/debian/ jessie mysql-5.6" > /etc/apt/sources.list.d/mysql.list

#Установка mysql 5.6 c пустым root паролем
RUN { \
                echo mysql-community-server mysql-community-server/root-pass password ''; \
                echo mysql-community-server mysql-community-server/re-root-pass password ''; \
                echo mysql-community-server mysql-community-server/remove-test-db select false; \
        } | debconf-set-selections \
        && apt-get update \
        && apt-get install -y mysql-server=5.6.30-1debian8 \
        && rm -rf /var/lib/apt/lists/* 

# Комментим bind-address в /etc/mysql/my.cnf и добавляем skip-host-cache\nskip-name-resolve в /etc/mysql/my.cnf
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf \
        && echo 'skip-host-cache\nskip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf \
        && mv /tmp/my.cnf /etc/mysql/my.cnf

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
