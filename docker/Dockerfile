ARG php
FROM php:${php}-fpm-alpine

ARG redis

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
        bcmath \
        gd \
        gettext \
        intl \
        mbstring \
        mysqli \
        pcntl \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        redis-${redis} \
        soap \
        sockets \
        xsl \
        zip

RUN cp "/etc/ssl/cert.pem" /opt/cert.pem

ARG ini_file

COPY --chmod=755 /runtime/bootstrap /opt/bootstrap
COPY --chmod=755 /runtime/bootstrap.php /opt/bootstrap.php
COPY /runtime/${ini_file} /usr/local/etc/php/php.ini

ENTRYPOINT []

CMD /opt/bootstrap