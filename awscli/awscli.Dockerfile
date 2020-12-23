# Install AWS CLI

FROM amazonlinux:latest as awsclibuilder

WORKDIR /root

RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

RUN yum update -y && yum install -y unzip

RUN unzip awscli-bundle.zip && cd awscli-bundle;

RUN ./awscli-bundle/install -i /opt/awscli -b /opt/awscli/aws

# Copy Everything To The Base Container

FROM amazonlinux:2

ENV INSTALL_DIR="/opt/vapor"

ENV PATH="/opt/bin:${PATH}" \
    LD_LIBRARY_PATH="${INSTALL_DIR}/lib64:${INSTALL_DIR}/lib"

RUN mkdir -p /opt

WORKDIR /opt

COPY --from=awsclibuilder /opt/awscli/lib/python2.7/site-packages/ /opt/awscli/
COPY --from=awsclibuilder /opt/awscli/bin/ /opt/awscli/bin/
COPY --from=awsclibuilder /opt/awscli/bin/aws /opt/awscli/aws
COPY --from=awsclibuilder /usr/lib64/libpython2.7.so.* /opt/awscli/lib/
COPY --from=awsclibuilder /usr/lib64/libpthread.so.* /opt/awscli/lib/
COPY --from=awsclibuilder /usr/lib64/libexpat.so.* /opt/awscli/lib/
COPY --from=awsclibuilder /usr/lib64/libdl.so.* /opt/awscli/lib/
COPY --from=awsclibuilder /usr/lib64/libutil.so.* /opt/awscli/lib/
COPY --from=awsclibuilder /usr/lib64/libm.so.* /opt/awscli/lib/
COPY --from=awsclibuilder /usr/lib64/libc.so.* /opt/awscli/lib/
COPY --from=awsclibuilder /usr/lib64/ld-linux-x86-64.so.* /opt/awscli/lib/
COPY --from=awsclibuilder /usr/lib64/python2.7/ /opt/awscli/lib/python2.7/
COPY --from=awsclibuilder /usr/lib64/python2.7/lib-dynload/ /opt/awscli/lib/python2.7/lib-dynload/

RUN LD_LIBRARY_PATH= yum -y install zip

RUN rm -rf /opt/awscli/pip* /opt/awscli/setuptools* /opt/awscli/awscli/examples
