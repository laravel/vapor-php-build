FROM --platform=linux/amd64 amazonlinux:2

WORKDIR /tmp

# Lock To Proper Release

RUN sed -i 's/releasever=latest/releasever=amzn2/' /etc/yum.conf

# Install Development Tools

RUN set -xe \
    && yum makecache \
    && yum groupinstall -y "Development Tools"  --setopt=group_package_types=mandatory,default

# Install CMake

RUN yum -y install openssl-devel perl-IPC-Cmd

RUN  set -xe \
    && mkdir -p /tmp/cmake \
    && cd /tmp/cmake \
    && curl -Ls  https://github.com/Kitware/CMake/releases/download/v3.27.6/cmake-3.27.6.tar.gz \
    | tar xzC /tmp/cmake --strip-components=1 \
    && ./bootstrap --prefix=/usr/local \
    && make -j $(nproc) \
    && make install
