FROM amazonlinux:2018.03

WORKDIR /tmp

# Lock To Proper Release

RUN sed -i 's/releasever=latest/releaserver=2018.03/' /etc/yum.conf

# Install Development Tools

RUN set -xe \
    && yum makecache \
    && yum groupinstall -y "Development Tools"  --setopt=group_package_types=mandatory,default

# Install CMake

RUN  set -xe \
    && mkdir -p /tmp/cmake \
    && cd /tmp/cmake \
    && curl -Ls  https://github.com/Kitware/CMake/releases/download/v3.13.2/cmake-3.13.2.tar.gz \
    | tar xzC /tmp/cmake --strip-components=1 \
    && ./bootstrap --prefix=/usr/local \
    && make \
    && make install

RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

RUN unzip awscli-bundle.zip

RUN awscli-bundle/install -i /opt/awscli -b /opt/awscli/aws