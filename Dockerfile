FROM php:8.1-fpm-alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.cloud.tencent.com/g' /etc/apk/repositories

RUN apk add -u --no-cache tzdata \
 && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN apk upgrade && \
    apk add --no-cache curl \
        curl-dev \
        autoconf \
        openssl \
        gcc \
        make \
        g++ \
        zlib-dev \
        icu-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libzip-dev \
        librdkafka-dev && \
    docker-php-ext-install  pdo_mysql opcache sockets bcmath pcntl && \
    docker-php-source delete

RUN pecl install redis memcached rdkafka \
    && docker-php-ext-enable redis memcached rdkafka 

RUN apk del autoconf gcc make g++ \
    && rm -fr /var/cache/apk/* /tmp/* /usr/share/man

WORKDIR /var/www/html


ENV TZ=Asia/Shanghai
ENV APP_ENV=product
ENV PHP_DATE_TIMEZONE="Asia/Shanghai"
ENV PHP_ERROR_LOG="/proc/self/fd/2"
ENV PHP_LOG_LEVEL="notice"
ENV PHP_PROCESS_MAX=0
ENV PHP_RLIMIT_FILES=51200
ENV PHP_RLIMIT_CORE=0
ENV PHP_USER=www-data
ENV PHP_GROUP=www-data
ENV PHP_LISTEN=0.0.0.0:9000
ENV PHP_PM=static
ENV PHP_PM_MAX_CHILDREN=20
ENV PHP_PM_START_SERVERS=4
ENV PHP_PM_MIN_SPARE_SERVERS=2
ENV PHP_PM_MAX_SPARE_SERVERS=10
ENV PHP_PM_PROCESS_IDLE_TIMEOUT=10s
ENV PHP_PM_MAX_REQUESTS=10000
ENV PHP_SLOWLOG="/proc/self/fd/2"
ENV PHP_REQUEST_SLOWLOG_TIMEOUT="2s"
ENV PHP_REQUEST_TERMINATE_TIMEOUT="20s"
ENV PHP_MAX_EXECUTION_TIME=600
ENV PHP_MAX_INPUT_TIME=60
ENV PHP_MEMORY_LIMIT=384M
ENV PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT"
ENV PHP_DISPLAY_ERRORS="Off"
ENV PHP_DISPLAY_STARTUP_ERRORS="Off"
ENV PHP_POST_MAX_SIZE=100M
ENV PHP_UPLOAD_MAX_FILESIZE=300M
ENV PHP_MAX_FILE_UPLOADS=20
ENV PHP_ACCESS_LOG="/dev/null"
ENV PHP_TRACK_ERRORS=Off
ENV PHP_ACCESS_FORMAT="{ \"type\": \"access\", \"time\": \"%t\", \"environment\": \"%{APP_ENV}e\", \"method\": \"%m\", \"request_uri\": \"%r%Q%q\", \"status_code\": \"%s\", \"cost_time\": %{mili}d, \"cpu_usage\": { \"user\" : %{user}C, \"system\": %{system}C, \"total\": %{total}C }, \"memory_usage\": %{bytes}M, \"remote_ip\": \"%R\", \"module\": \"php-fpm\", \"log_type\": \"access-log\" }"
ENV PHP_MAX_INPUT_VARS=2000

ENV PHP_OPCACHE_ENABLE=1
ENV PHP_OPCACHE_ENABLE_CLI=1
ENV PHP_OPCACHE_MEMORY_CONSUMPTION=384
ENV PHP_OPCACHE_INTERNED_STRINGS_BUFFER=16
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES=100000
ENV PHP_OPCACHE_MAX_WASTED_PERCENTAGE=5
ENV PHP_OPCACHE_USE_CWD=1
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=0
ENV PHP_OPCACHE_REVALIDATE_FREQ=0
ENV PHP_OPCACHE_FAST_SHUTDOWN=1
ENV PHP_OPCACHE_CONSISTENCY_CHECKS=0
ENV PHP_OPCACHE_BLACKLIST_FILENAME=/var/www/html/.opcacheignore

COPY php-config/php.ini "$PHP_INI_DIR"
COPY php-config/conf.d/ "$PHP_INI_DIR"/conf.d/
COPY php-config/php-fpm.conf /usr/local/etc/
COPY php-config/www.conf /usr/local/etc/php-fpm.d/

EXPOSE 9000

RUN rm -fr /usr/local/etc/php-fpm.d/zz-docker.conf
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["php-fpm"]

