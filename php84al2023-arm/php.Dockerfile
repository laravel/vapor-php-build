FROM --platform=linux/arm64 vapor/runtime/compiler:latest as php_builder

SHELL ["/bin/bash", "-c"]

ENV BUILD_DIR="/tmp/build"
ENV INSTALL_DIR="/opt/vapor"

# Configure Default Compiler Variables

ENV PKG_CONFIG_PATH="${INSTALL_DIR}/lib64/pkgconfig:${INSTALL_DIR}/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig" \
    PKG_CONFIG="/usr/bin/pkg-config" \
    PATH="${INSTALL_DIR}/bin:${PATH}"

ENV LD_LIBRARY_PATH="${INSTALL_DIR}/lib64:${INSTALL_DIR}/lib"

ENV CMAKE_BUILD_PARALLEL_LEVEL=4
ENV MAKEFLAGS='-j4'

# Create All The Necessary Build Directories

RUN mkdir -p ${BUILD_DIR}  \
    ${INSTALL_DIR}/bin \
    ${INSTALL_DIR}/doc \
    ${INSTALL_DIR}/etc/php \
    ${INSTALL_DIR}/etc/php/conf.d \
    ${INSTALL_DIR}/include \
    ${INSTALL_DIR}/lib \
    ${INSTALL_DIR}/lib64 \
    ${INSTALL_DIR}/libexec \
    ${INSTALL_DIR}/sbin \
    ${INSTALL_DIR}/share

RUN LD_LIBRARY_PATH= yum install -y readline-devel oniguruma-devel libpq-devel zlib-devel libzip-devel openssl-devel libcurl-devel libsodium-devel libicu-devel gettext-devel libxslt-devel ImageMagick-devel libpng-devel libjpeg-devel

# Build SQLite

ARG sqlite
ENV VERSION_SQLITE=${sqlite}
ENV SQLITE_BUILD_DIR=${BUILD_DIR}/libsqlite3

RUN LD_LIBRARY_PATH= yum install -y tcl

RUN set -xe; \
    mkdir -p ${SQLITE_BUILD_DIR}; \
    curl -Ls https://github.com/sqlite/sqlite/archive/refs/tags/version-${VERSION_SQLITE}.tar.gz \
    | tar xzC ${SQLITE_BUILD_DIR} --strip-components=1

WORKDIR ${SQLITE_BUILD_DIR}/
RUN CFLAGS="-Os" CPPFLAGS="-Os" ./configure --prefix=${INSTALL_DIR}
RUN make && make install

# Build PHP

ARG php
ENV VERSION_PHP=${php}
ENV PHP_BUILD_DIR=${BUILD_DIR}/php

RUN set -xe; \
    mkdir -p ${PHP_BUILD_DIR}; \
    curl -Ls https://php.net/distributions/php-${VERSION_PHP}.tar.gz \
    | tar xzC ${PHP_BUILD_DIR} --strip-components=1

# Configure The PHP Build

WORKDIR  ${PHP_BUILD_DIR}/

RUN set -xe \
 && ./buildconf --force \
 && CFLAGS="-fstack-protector-strong -fpic -fpie -Os -I${INSTALL_DIR}/include -I/usr/include -ffunction-sections -fdata-sections" \
    CPPFLAGS="-fstack-protector-strong -fpic -fpie -Os -I${INSTALL_DIR}/include -I/usr/include -ffunction-sections -fdata-sections" \
    LDFLAGS="-L${INSTALL_DIR}/lib64 -L${INSTALL_DIR}/lib -Wl,-O1 -Wl,--strip-all -Wl,--hash-style=both -pie" \
    ./configure \
        --prefix=${INSTALL_DIR} \
        --enable-option-checking=fatal \
        --with-config-file-path=${INSTALL_DIR}/etc/php \
        --with-config-file-scan-dir=${INSTALL_DIR}/etc/php/conf.d:/var/task/php/conf.d \
        --enable-fpm \
        --disable-cgi \
        --enable-cli \
        --with-jpeg=${INSTALL_DIR} \
        --with-xsl=${INSTALL_DIR} \
        --enable-gd \
        --disable-phpdbg \
        # --disable-phpdbg-webhelper \
        --with-sodium \
        --with-readline \
        --with-openssl \
        --with-zlib \
        --with-curl \
        --enable-bcmath \
        --enable-sockets \
        --enable-exif \
        --enable-ftp \
        --with-gettext \
        --with-pear \
        --enable-mbstring \
        --enable-soap \
        --with-pdo-mysql=mysqlnd \
        --enable-pcntl \
        --with-zip \
        --with-pdo-pgsql \
        --enable-intl=shared

RUN make -j $(nproc)

# Override PEAR URL Since It Is Down

RUN set -xe; \
    make install PEAR_INSTALLER_URL='https://github.com/pear/pearweb_phars/raw/master/install-pear-nozlib.phar'; \
    { find ${INSTALL_DIR}/bin ${INSTALL_DIR}/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; }; \
    make clean; \
    cp php.ini-production ${INSTALL_DIR}/etc/php/php.ini

# Build Redis (https://pecl.php.net/package/redis/)

ARG redis
ENV VERSION_REDIS=${redis}

RUN pecl install -f redis-${VERSION_REDIS}

# Copy libraries

RUN cp -aL /usr/lib64/libtinfo.so.6 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libonig.so.5 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libsodium.so.26 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libzip.so.5 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libpq.so.5 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libldap_r-2.4.so.2 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/liblber-2.4.so.2 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libsasl2.so.3 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libicuio.so.67 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libicui18n.so.67 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libicuuc.so.67 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libicudata.so.67 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libxslt.so.1 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libexslt.so.0 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libpng16.so.16 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libjpeg.so.62 ${INSTALL_DIR}/lib64/
RUN cp -aL /usr/lib64/libcrypt.so.2 ${INSTALL_DIR}/lib64/
RUN cp -aL /opt/vapor/lib/libsqlite3.so.0 ${INSTALL_DIR}/lib64/

# Strip All Unneeded Symbols

RUN find ${INSTALL_DIR} -type f -name "*.so*" -o -name "*.a"  -exec strip --strip-unneeded {} \;
RUN find ${INSTALL_DIR} -type f -executable -exec sh -c "file -i '{}' | grep -q 'x-executable; charset=binary'" \; -print|xargs strip --strip-all

# Symlink All Binaries / Libaries

RUN mkdir -p /opt/bin
RUN mkdir -p /opt/lib
RUN mkdir -p /opt/lib/curl

RUN cp /opt/vapor/bin/* /opt/bin
RUN cp /opt/vapor/sbin/* /opt/bin

RUN cp /opt/vapor/lib/php/extensions/no-debug-non-zts-20240924/* /opt/bin

RUN cp /etc/ssl/cert.pem /opt/lib/curl/cert.pem
RUN cp /opt/vapor/lib64/* /opt/lib || true


# Copy Everything To The Base Container

FROM amazonlinux:2023

ENV INSTALL_DIR="/opt/vapor"

ENV PATH="/opt/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/lib:/opt/lib/bref:/lib64:/usr/lib64:/var/runtime:/var/runtime/lib:/var/task:/var/task/lib"

RUN mkdir -p /opt

WORKDIR /opt

COPY --from=php_builder /opt /opt
RUN LD_LIBRARY_PATH= yum -y install zip


COPY --chmod=755 /runtime/bootstrap /opt
COPY --chmod=755 /runtime/bootstrap.php /opt

RUN rm -rf vapor/
RUN mkdir -p vapor/etc/php/conf.d
COPY /runtime/php.ini vapor/etc/php/conf.d
