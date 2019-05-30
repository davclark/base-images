# Copyright (c) Gigantum

# Note, some docker commands taken from/inspired by the standard docker-stacks maintained
# by the Jupyter team: https://github.com/jupyter/docker-stacks/
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

FROM ubuntu:16.04
LABEL maintainer="Gigantum <support@gigantum.com>"
ENV DEBIAN_FRONTEND noninteractive

# Install system level dependencies
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    gcc \
    g++ \
    make \
    locales \
    fonts-liberation \
    gosu \
    tzdata \
    git && \
    apt-get clean

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Setup environment variables
ENV CONDA_DIR=/opt/conda \
    GIGANTUM_SHARE=/mnt/share \
    GIGANTUM_WORKDIR=/mnt/labbook \
    SHELL=/bin/bash \
    MINICONDA_VERSION=4.5.11 \
    MINICONDA_MD5=458324438b7b0e5afcc272b63d44195d \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    JUPYTER_RUNTIME_DIR=$GIGANTUM_SHARE/jupyter/runtime

# Install conda and python
RUN cd /tmp && wget --quiet https://repo.continuum.io/miniconda/Miniconda2-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "$MINICONDA_MD5 *Miniconda2-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda2-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda2-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda update --quiet --yes conda && \
    conda update --all --quiet --yes && \
    # notebook 5.3 through 5.7.1 have security holes
    conda install --quiet --yes -c conda-forge 'jupyterlab=0.33' 'notebook>=5.7.2,<5.8' && \
    conda install pip && \
    conda clean --all

#
# neurodebian
#

# https://bugs.debian.org/830696 (apt uses gpgv by default in newer releases, rather than gpg)
RUN set -x \
	&& apt-get update \
	&& { \
		which gpg \
		|| apt-get install -y --no-install-recommends gnupg \
	; } \
# Ubuntu includes "gnupg" (not "gnupg2", but still 2.x), but not dirmngr, and gnupg 2.x requires dirmngr
# so, if we're not running gnupg 1.x, explicitly install dirmngr too
	&& { \
		gpg --version | grep -q '^gpg (GnuPG) 1\.' \
		|| apt-get install -y --no-install-recommends dirmngr \
	; } \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir ~/.gnupg
RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# apt-key is a bit finicky during "docker build" with gnupg 2.x, so install the repo key the same way debian-archive-keyring does (/etc/apt/trusted.gpg.d)
# this makes "apt-key list" output prettier too!
RUN set -x \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys DD95CC430502E37EF840ACEEA5D32F012649A5A9 \
	&& gpg --batch --export DD95CC430502E37EF840ACEEA5D32F012649A5A9 > /etc/apt/trusted.gpg.d/neurodebian.gpg \
	&& rm -rf "$GNUPGHOME" \
	&& apt-key list | grep neurodebian

RUN { \
	echo 'deb http://neuro.debian.net/debian xenial main'; \
	echo 'deb http://neuro.debian.net/debian data main'; \
	echo '#deb-src http://neuro.debian.net/debian-devel xenial main'; \
} > /etc/apt/sources.list.d/neurodebian.sources.list

# Minimalistic package to assist with freezing the APT configuration
# which would be coming from neurodebian repo.
# Also install and enable eatmydata to be used for all apt-get calls
# to speed up docker builds.
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends neurodebian-freeze eatmydata \
	&& ln -s /usr/bin/eatmydata /usr/local/bin/apt-get \
	&& rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's,main *$,main contrib non-free,g' /etc/apt/sources.list.d/neurodebian.sources.list; grep -q 'deb .* multiverse$' /etc/apt/sources.list || sed -i -e 's,universe *$,universe multiverse,g' /etc/apt/sources.list

#
# CPAC docker file.
#
RUN mkdir -p /code 

# Install the validator
RUN apt-get update && \
     apt-get install -y curl && \
     curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
     apt-get install -y nodejs && \
     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN npm install -g bids-validator

# Install Ubuntu dependencies
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      cmake \
      git \
      graphviz \
      graphviz-dev \
      gsl-bin \
      libcanberra-gtk-module \
      libexpat1-dev \
      libgiftiio-dev \
      libglib2.0-dev \
      libglu1-mesa \
      libglu1-mesa-dev \
      libjpeg-progs \
      libgl1-mesa-dri \
      libglw1-mesa \
      libxml2 \
      libxml2-dev \
      libxext-dev \
      libxft2 \
      libxft-dev \
      libxi-dev \
      libxmu-headers \
      libxmu-dev \
      libxpm-dev \
      libxslt1-dev \
      m4 \
      make \
      mesa-common-dev \
      mesa-utils \
      netpbm \
      pkg-config \
      tcsh \
      unzip \
      xvfb \
      xauth \
      zlib1g-dev

# Install 16.04 dependencies
RUN apt-get update && \
    apt-get install -y \
      dh-autoreconf \
      libgsl-dev \
      libmotif-dev \
      libtool \
      libx11-dev \
      libxext-dev \
      x11proto-xext-dev \
      x11proto-print-dev \
      xutils-dev

# Compiles libxp- this is necessary for some newer versions of Ubuntu
# where the is no Debian package available.
RUN git clone git://anongit.freedesktop.org/xorg/lib/libXp /tmp/libXp && \
    cd /tmp/libXp && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd / && \
    rm -rf /tmp/libXp

# Installing and setting up c3d
RUN mkdir -p /opt/c3d && \
    curl -sSL "http://downloads.sourceforge.net/project/c3d/c3d/1.0.0/c3d-1.0.0-Linux-x86_64.tar.gz" \
    | tar -xzC /opt/c3d --strip-components 1
ENV C3DPATH /opt/c3d/
ENV PATH $C3DPATH/bin:$PATH

# install AFNI
COPY required_afni_pkgs.txt /opt/required_afni_pkgs.txt
RUN libs_path=/usr/lib/x86_64-linux-gnu && \
    if [ -f $libs_path/libgsl.so.19 ]; then \
           ln $libs_path/libgsl.so.19 $libs_path/libgsl.so.0; \
    fi && \
    mkdir -p /opt/afni && \
    curl -sO https://afni.nimh.nih.gov/pub/dist/tgz/linux_openmp_64.tgz && \
    tar zxv -C /opt/afni --strip-components=1 -f linux_openmp_64.tgz $(cat /opt/required_afni_pkgs.txt) && \
    rm -rf linux_openmp_64.tgz

# set up AFNI
ENV PATH=/opt/afni:$PATH

# install FSL
RUN apt-get update  && \
    apt-get install -y --no-install-recommends \
                    fsl-core \
                    fsl-atlases \
                    fsl-mni152-templates

# setup FSL environment
ENV FSLDIR=/usr/share/fsl/5.0 \
    FSLOUTPUTTYPE=NIFTI_GZ \
    FSLMULTIFILEQUIT=TRUE \
    POSSUMDIR=/usr/share/fsl/5.0 \
    LD_LIBRARY_PATH=/usr/lib/fsl/5.0:$LD_LIBRARY_PATH \
    FSLTCLSH=/usr/bin/tclsh \
    FSLWISH=/usr/bin/wish \
    PATH=/usr/lib/fsl/5.0:$PATH

# install CPAC resources into FSL
RUN cd /tmp && \
    curl -sO http://fcon_1000.projects.nitrc.org/indi/cpac_resources.tar.gz && \
    tar xfz cpac_resources.tar.gz && \
    cd cpac_image_resources && \
    cp -n MNI_3mm/* $FSLDIR/data/standard && \
    cp -n MNI_4mm/* $FSLDIR/data/standard && \
    cp -n symmetric/* $FSLDIR/data/standard && \
    cp -nr tissuepriors/2mm $FSLDIR/data/standard/tissuepriors && \
    cp -nr tissuepriors/3mm $FSLDIR/data/standard/tissuepriors && \
    cp -n HarvardOxford-lateral-ventricles-thr25-2mm.nii.gz $FSLDIR/data/atlases/HarvardOxford

# install ANTs
RUN apt-get update && \
    apt-get install -y ants

# install ICA-AROMA
RUN mkdir -p /opt/ICA-AROMA
RUN curl -sL https://github.com/rhr-pruim/ICA-AROMA/archive/v0.4.3-beta.tar.gz | tar -xzC /opt/ICA-AROMA --strip-components 1
RUN chmod +x /opt/ICA-AROMA/ICA_AROMA.py
ENV PATH=/opt/ICA-AROMA:$PATH

# RB alread have conda
## install miniconda
#RUN curl -sO https://repo.continuum.io/miniconda/Miniconda-3.8.3-Linux-x86_64.sh && \
#    bash Miniconda-3.8.3-Linux-x86_64.sh -b -p /usr/local/miniconda && \
#    rm Miniconda-3.8.3-Linux-x86_64.sh
#
## update path to include conda
#ENV PATH=/usr/local/miniconda/bin:$PATH

# install blas dependency first
RUN conda install -y \
        blas

# install conda dependencies
RUN conda install -y  \
        cython==0.26 \
        jinja2==2.7.2 \
        matplotlib=2.0.2 \
        networkx==1.11 \
        nose==1.3.7 \
        numpy==1.13.0 \
        pandas==0.23.4 \
        scipy==0.19.1 \
        traits==4.6.0 \
        wxpython==3.0.0.0 \
        pip

# install python dependencies
COPY requirements.txt /opt/requirements.txt
RUN pip install --upgrade pip==9.0.1
RUN pip install -r /opt/requirements.txt
RUN pip install xvfbwrapper

# install cpac templates
COPY cpac_templates.tar.gz /cpac_resources/cpac_templates.tar.gz
RUN tar xzvf /cpac_resources/cpac_templates.tar.gz && \
    rm -f /cpac_resources/cpac_templates.tar.gz

# Get atlases
RUN mkdir /ndmg_atlases && \
    curl https://s3.amazonaws.com/mrneurodata/data/resources/ndmg_atlases.zip -o /ndmg_atlases/ndmg_atlases.zip && \
    cd /ndmg_atlases && unzip /ndmg_atlases/ndmg_atlases.zip && \
    rm /ndmg_atlases/ndmg_atlases.zip

# clean up
RUN apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## install cpac
COPY v1.4.1.zip /
RUN unzip v1.4.1.zip && mv /C-PAC-1.4.1/* /code && pip install -e /code

## make the run.py executable
RUN chmod +x /code/run.py

# copy useful pipeline scripts
COPY default_pipeline.yaml /cpac_resources/default_pipeline.yaml
COPY test_pipeline.yaml /cpac_resources/test_pipeline.yaml
COPY pipe-test_ci.yml /cpac_resources/pipe-test_ci.yml

#ENTRYPOINT ["/code/run.py"]



# Expose port for jupyterlab
EXPOSE 8888

# Set working dir
WORKDIR $GIGANTUM_WORKDIR



