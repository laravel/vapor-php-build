FROM amazonlinux:2023

SHELL ["/bin/bash", "-c"]

ENV BUILD_DIR="/tmp/build"
ENV INSTALL_DIR="/opt/vapor"
ENV CMAKE_BUILD_PARALLEL_LEVEL=4
ENV MAKEFLAGS='-j4'
ENV LD_LIBRARY_PATH="${INSTALL_DIR}/lib64:${INSTALL_DIR}/lib"
ENV PKG_CONFIG_PATH="${INSTALL_DIR}/lib64/pkgconfig:${INSTALL_DIR}/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig" \
    PKG_CONFIG="/usr/bin/pkg-config" \
    PATH="${INSTALL_DIR}/bin:${PATH}"

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
    ${INSTALL_DIR}/share \
    /opt/bin \
    /opt/lib \
    /opt/lib/curl

RUN set -xe \
    && dnf makecache \
    && dnf groupinstall -y "Development Tools" \
    && dnf install -y \
        cmake \
        openssl-devel \
        readline-devel \
        oniguruma-devel \
        libpq-devel \
        zlib-devel \
        libzip-devel \
        libcurl-devel \
        libsodium-devel \
        libicu-devel \
        gettext-devel \
        libxslt-devel \
        ImageMagick-devel \
        libpng-devel \
        libjpeg-devel \
        tcl \
        zip \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ---------- Download pie ----------

RUN curl -fsSL -o /usr/local/bin/pie https://github.com/php/pie/releases/latest/download/pie.phar \
    && chmod +x /usr/local/bin/pie

# ---------- Build SQLite ----------

ENV VERSION_SQLITE=3.46.1
ENV SQLITE_BUILD_DIR=${BUILD_DIR}/libsqlite3

RUN set -xe; \
    mkdir -p ${SQLITE_BUILD_DIR}; \
    curl -Ls https://github.com/sqlite/sqlite/archive/refs/tags/version-${VERSION_SQLITE}.tar.gz \
    | tar xzC ${SQLITE_BUILD_DIR} --strip-components=1

WORKDIR ${SQLITE_BUILD_DIR}/
RUN CFLAGS="-Os" CPPFLAGS="-Os" ./configure --prefix=${INSTALL_DIR} \
    && make && make install

# ---------- Build PHP ----------
ARG php
ENV VERSION_PHP=${php}
ENV PHP_BUILD_DIR=${BUILD_DIR}/php

RUN set -xe; \
    mkdir -p ${PHP_BUILD_DIR}; \
    curl -Ls https://php.net/distributions/php-${VERSION_PHP}.tar.gz \
    | tar xzC ${PHP_BUILD_DIR} --strip-components=1

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
        --enable-mbstring \
        --enable-soap \
        --with-pdo-mysql=mysqlnd \
        --enable-pcntl \
        --with-zip \
        --with-pdo-pgsql \
        --enable-intl=shared

RUN make -j $(nproc)

RUN set -xe; \
    make install; \
    { find ${INSTALL_DIR}/bin ${INSTALL_DIR}/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; }; \
    make clean; \
    cp php.ini-production ${INSTALL_DIR}/etc/php/php.ini

# ---------- Build redis ----------

ARG redis
ENV VERSION_REDIS=${redis}

RUN pie install --no-cache phpredis/phpredis:${VERSION_REDIS}

# ---------- Copy libraries ----------

RUN cp -aL \
  /usr/lib64/libtinfo.so.6 \
  /usr/lib64/libonig.so.5 \
  /usr/lib64/libsodium.so.26 \
  /usr/lib64/libzip.so.5 \
  /usr/lib64/libpq.so.5 \
  /usr/lib64/libldap_r-2.4.so.2 \
  /usr/lib64/liblber-2.4.so.2 \
  /usr/lib64/libsasl2.so.3 \
  /usr/lib64/libicuio.so.67 \
  /usr/lib64/libicui18n.so.67 \
  /usr/lib64/libicuuc.so.67 \
  /usr/lib64/libicudata.so.67 \
  /usr/lib64/libxslt.so.1 \
  /usr/lib64/libexslt.so.0 \
  /usr/lib64/libpng16.so.16 \
  /usr/lib64/libjpeg.so.62 \
  /usr/lib64/libcrypt.so.2 \
  /opt/vapor/lib/libsqlite3.so.0 \
  /opt/lib/

# ---------- Copy PHP binaries ----------

RUN cp ${INSTALL_DIR}/bin/php /opt/bin/php \
    && cp ${INSTALL_DIR}/sbin/php-fpm /opt/bin/php-fpm \
    && cp $(php -r 'echo ini_get("extension_dir");')/* /opt/bin/ \
    && cp /etc/ssl/cert.pem /opt/lib/curl/cert.pem \

# ---------- Stripe unneded symbols ----------

RUN find /opt -type f -name "*.so*" -o -name "*.a"  -exec strip --strip-unneeded {} \;
RUN find /opt -type f -executable -exec sh -c "file -i '{}' | grep -q 'x-executable; charset=binary'" \; -print|xargs strip --strip-all

# ---------- Prepare for export ----------

RUN rm -rf /opt/vapor/ \
    && mkdir -p /opt/vapor/etc/php/conf.d

ARG ini_file

COPY --chmod=755 /runtime/bootstrap /opt
COPY --chmod=755 /runtime/bootstrap.php /opt
COPY /runtime/${ini_file} /opt/vapor/etc/php/conf.d/php.ini