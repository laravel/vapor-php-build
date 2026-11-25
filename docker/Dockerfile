ARG php
FROM php:${php}-fpm-alpine

RUN apk --update add \
    wget \
    curl \
    build-base \
    libmcrypt-dev \
    libxml2-dev \
    pcre-dev \
    zlib-dev \
    autoconf \
    oniguruma-dev \
    openssl \
    openssl-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    jpeg-dev \
    libpng-dev \
    imagemagick-dev \
    imagemagick \
    postgresql-dev \
    libzip-dev \
    gettext-dev \
    libxslt-dev \
    libgcrypt-dev \
    linux-headers && \
    rm /var/cache/apk/*

RUN docker-php-ext-install \
    mysqli \
    mbstring \
    pdo \
    pdo_mysql \
    xml \
    pcntl \
    bcmath \
    pdo_pgsql \
    zip \
    intl \
    gettext \
    soap \
    sockets \
    xsl \
    gd

ARG redis

RUN curl -fsSL -o /usr/local/bin/pie \
    https://github.com/php/pie/releases/latest/download/pie.phar \
    && chmod +x /usr/local/bin/pie

RUN pie install --no-cache phpredis/phpredis:dev-develop

RUN cp "/etc/ssl/cert.pem" /opt/cert.pem

ARG ini_file

COPY --chmod=755 /runtime/bootstrap /opt/bootstrap
COPY --chmod=755 /runtime/bootstrap.php /opt/bootstrap.php
COPY /runtime/${ini_file} /usr/local/etc/php/php.ini

ENTRYPOINT []

CMD /opt/bootstrap