#!/bin/bash
set -eo pipefail

MYSQL_ROOT_PASSWORD=123123

if [ "$1" = 'mysqld' ]; then

        #запуск mysqld
        "$@" --skip-networking &

        #запоминаем pid процесса
        pid="$!"

        #Дожидаемся запуска mysql
        mysql=( mysql --protocol=socket -uroot )

        for i in {30..0}; do
            if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
                break
            fi
            echo 'MySQL init process in progress...'
            sleep 1
        done
        if [ "$i" = 0 ]; then
            echo >&2 'MySQL init process failed.'
            exit 1
        fi

        #  Назначеам руту пароль, права для коннекта и создания файлов
        "${mysql[@]}" <<-EOSQL
            SET @@SESSION.SQL_LOG_BIN=0;
            DELETE FROM mysql.user ;
            CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
            GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
            GRANT FILE ON *.* TO 'root'@'%';
            DROP DATABASE IF EXISTS test ;
            FLUSH PRIVILEGES ;
EOSQL
        
        #завершаем процесс mysqld
        if ! kill -s TERM "$pid" || ! wait "$pid"; then
            echo >&2 'MySQL init process failed.'
            exit 1
        fi

        echo
        echo 'MySQL init process done. Ready for start up.'
        echo
fi

#Запуск CMD
exec "$@"