FROM --platform=linux/amd64 amazonlinux:2023

WORKDIR /tmp

RUN set -xe \
    && dnf makecache \
    && dnf groupinstall -y "Development Tools" \
    && dnf install -y cmake openssl-devel \
    && dnf clean all \
    && rm -rf /var/cache/dnf
