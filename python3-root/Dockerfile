# Copyright (c) Gigantum

# Note, some docker commands taken from/inspired by the standard docker-stacks maintained
# by the Jupyter team: https://github.com/jupyter/docker-stacks/
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM gigantum/python3-minimal:1effaaea-2018-05-23
LABEL maintainer="Gigantum <hello@gigantum.io>"

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    ccache \
    cmake \
    dcap-dev \
    g++ \
    gcc \
    gfal2 \
    gfortran \
    git \
    git-lfs \
    graphviz-dev \
    libavahi-compat-libdnssd-dev \
    libcfitsio-dev \
    libfftw3-dev \
    libftgl-dev \
    libgfal2-dev \
    libgif-dev \
    libgl2ps-dev \
    libglew-dev \
    libgsl0-dev \
    libjemalloc-dev \
    libjpeg-dev \
    libkrb5-dev \
    libldap2-dev \
    libmysqlclient-dev \
    liboce-ocaf-dev \
    liboce-visualization-dev \
    libodbc1 \
    libpcre++-dev \
    libpq-dev \
    libpythia8-dev \
    libqt4-dev \
    libsqlite3-dev \
    libtbb-dev \
    libtiff-dev \
    libx11-dev \
    libxext-dev \
    libxft-dev \
    libxml2-dev \
    libxpm-dev \
    locales \
    lsb-release \
    make \
    python \
    python-dev \
    python-numpy-dev \
    srm-ifce-dev \
    sudo \
    uuid-dev && \
    apt-get clean 

ADD root.ubu18.gig.minimal.tar.gz /opt
#RUN git clone https://github.com/randalburns/cernroot.ubu18.git && cd cernroot.ubu18 && git lfs pull && \
#    tar -xvzf root_v6.14.00.Linux-ubuntu18-x86_64-gcc7.3.tar.gz -C /usr/local && cd .. && rm -rf cernroot.ubu18

