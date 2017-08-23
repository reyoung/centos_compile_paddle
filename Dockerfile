FROM reyoung/centos6u2gcc482
MAINTAINER Yu Yang <reyoung@126.com>
ARG UBUNTU_MIRROR
RUN /bin/bash -c 'if [[ -n ${UBUNTU_MIRROR} ]]; then sed -i 's#http://archive.ubuntu.com/ubuntu#${UBUNTU_MIRROR}#g' /etc/apt/sources.list; fi'

# ENV variables
ARG WITH_GPU
ARG WITH_AVX
ARG WITH_DOC
ARG WITH_STYLE_CHECK

ENV WOBOQ OFF
ENV WITH_GPU=${WITH_GPU:-OFF}
ENV WITH_AVX=${WITH_AVX:-ON}
ENV WITH_DOC=${WITH_DOC:-OFF}
ENV WITH_STYLE_CHECK=${WITH_STYLE_CHECK:-OFF}

ENV HOME /root

RUN wget -qO- https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz | \
    tar -xz -C /usr/local && \
    mkdir /root/gopath && \
    mkdir /root/gopath/bin && \
    mkdir /root/gopath/src
ENV GOROOT=/usr/local/go GOPATH=/root/gopath
# should not be in the same line with GOROOT definition, otherwise docker build could not find GOROOT.
ENV PATH=${PATH}:${GOROOT}/bin:${GOPATH}/bin
# install glide
RUN go get github.com/Masterminds/glide
RUN yum install -y zlib-devel patch openssl-devel boost-devel
COPY ./CompilePython27 /python_srcs/
COPY ./centos.patch /python_srcs/
RUN cd /python_srcs/ && patch -p0 < ./centos.patch
RUN /python_srcs/build.sh && mv /python_srcs/dist/ /opt/python
RUN /opt/python/install.sh && /opt/python/bin/pip install \
    numpy wheel docopt PyYAML sphinx sphinx-rtd-theme==0.1.9 recommonmark\
    pre-commit 'ipython==5.3.0' 'ipykernel==4.6.0' 'jupyter==1.0.0'\
    opencv-python certifi urllib3[secure]
ADD https://raw.githubusercontent.com/PaddlePaddle/Paddle/develop/python/requirements.txt /root/
RUN /opt/python/bin/pip install -r /root/requirements.txt
ADD ./build.sh /
VOLUME /paddle_dist 
CMD ["/build.sh"]
