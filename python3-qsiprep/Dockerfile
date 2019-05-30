# Copyright (c) Gigantum

# Note, some docker commands taken from/inspired by the standard docker-stacks maintained
# by the Jupyter team: https://github.com/jupyter/docker-stacks/
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

FROM ubuntu:16.04
LABEL maintainer="Gigantum <support@gigantum.com>"
ENV DEBIAN_FRONTEND noninteractive

# Install system level dependencies
RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
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
        git \
    && apt-get clean

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Setup environment variables
ENV CONDA_DIR=/opt/conda \
    GIGANTUM_SHARE=/mnt/share \
    GIGANTUM_WORKDIR=/mnt/labbook \
    SHELL=/bin/bash \
    MINICONDA_VERSION=4.5.12 \
    MINICONDA_MD5=866ae9dff53ad0874e1d1a60b1ad1ef8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    JUPYTER_RUNTIME_DIR=$GIGANTUM_SHARE/jupyter/runtime

# Install conda, python, and jupyter
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "$MINICONDA_MD5 *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    # We update conda explicitly to get any gains in performance, etc.
    conda update --quiet --yes conda && \
    conda update --all --quiet --yes && \
    # notebook 5.3 through 5.7.1 have security holes
    conda install --quiet --yes -c conda-forge 'jupyterlab=0.35' 'notebook>=5.7.2,<5.8' && \
    # This is currently installed by default by conda, but it's mission
    # critical so we make it explicit
    conda install pip && \
    conda install --quiet --yes nodejs && \
    pip install nbresuse && \
    # unlcear from statusbar docs if this is necessary for jupyterlab, but doesn't hurt
    jupyter serverextension enable --py nbresuse && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter labextension install @jupyterlab/statusbar && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /root/.cache/yarn && \
    rm -rf /root/.node-gyp && \
    conda remove --quiet --yes nodejs && \
    conda clean --all

# Pre-cache neurodebian key
COPY neurodebian.gpg /root/.neurodebian.gpg

# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    curl \
                    bzip2 \
                    ca-certificates \
                    gnupg2 \
                    xvfb \
                    cython3 \
                    build-essential \
                    autoconf \
                    libtool \
                    pkg-config && \
    curl -sSL http://neuro.debian.net/lists/xenial.us-ca.full >> /etc/apt/sources.list.d/neurodebian.sources.list && \
    apt-key add /root/.neurodebian.gpg && \
    (apt-key adv --refresh-keys --keyserver hkp://ha.pool.sks-keyservers.net 0xA5D32F012649A5A9 || true) && \
    apt-get update


# Installing freesurfer
RUN curl -sSL https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.1/freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.1.tar.gz | tar zxv --no-same-owner -C /opt \
    --exclude='freesurfer/trctrain' \
    --exclude='freesurfer/subjects/fsaverage_sym' \
    --exclude='freesurfer/subjects/fsaverage3' \
    --exclude='freesurfer/subjects/fsaverage4' \
    --exclude='freesurfer/subjects/cvs_avg35' \
    --exclude='freesurfer/subjects/cvs_avg35_inMNI152' \
    --exclude='freesurfer/subjects/bert' \
    --exclude='freesurfer/subjects/V1_average' \
    --exclude='freesurfer/average/mult-comp-cor' \
    --exclude='freesurfer/lib/cuda' \
    --exclude='freesurfer/lib/qt'

  ENV FSLDIR="/opt/fsl-5.0.11" \
      PATH="/opt/fsl-5.0.11/bin:$PATH"
  RUN apt-get update -qq \
      && apt-get install -y -q --no-install-recommends \
             bc \
             dc \
             file \
             libfontconfig1 \
             libfreetype6 \
             libgl1-mesa-dev \
             libglu1-mesa-dev \
             libgomp1 \
             libice6 \
             libxcursor1 \
             libxft2 \
             libxinerama1 \
             libxrandr2 \
             libxrender1 \
             libxt6 \
             wget \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
      && echo "Downloading FSL ..." \
      && mkdir -p /opt/fsl-5.0.11 \
      && curl -fsSL --retry 5 https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-5.0.11-centos6_64.tar.gz \
      | tar -xz -C /opt/fsl-5.0.11 --strip-components 1 \
      && echo "Installing FSL conda environment ..." \
      && bash /opt/fsl-5.0.11/etc/fslconf/fslpython_install.sh -f /opt/fsl-5.0.11

ENV FREESURFER_HOME=/opt/freesurfer \
    SUBJECTS_DIR=/opt/freesurfer/subjects \
    FUNCTIONALS_DIR=/opt/freesurfer/sessions \
    MNI_DIR=/opt/freesurfer/mni \
    LOCAL_DIR=/opt/freesurfer/local \
    FSFAST_HOME=/opt/freesurfer/fsfast \
    MINC_BIN_DIR=/opt/freesurfer/mni/bin \
    MINC_LIB_DIR=/opt/freesurfer/mni/lib \
    MNI_DATAPATH=/opt/freesurfer/mni/data \
    FMRI_ANALYSIS_DIR=/opt/freesurfer/fsfast
ENV PERL5LIB=$MINC_LIB_DIR/perl5/5.8.5 \
    MNI_PERL5LIB=$MINC_LIB_DIR/perl5/5.8.5 \
    PATH=$FREESURFER_HOME/bin:$FSFAST_HOME/bin:$FREESURFER_HOME/tktools:$MINC_BIN_DIR:$PATH

# Installing Neurodebian packages (FSL, AFNI, git)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    afni=16.2.07~dfsg.1-5~nd16.04+1

# Install DSI Studio
ENV PATH=$PATH:/opt/dsi-studio/dsi_studio_64
RUN apt-get install -y --no-install-recommends \
                    git \
                    qt5-qmake \
                    qt5-default \
                    libboost-all-dev \
                    zlib1g \
                    zlib1g-dev \
                    libqt5opengl5-dev \
                    unzip \
                    libgl1-mesa-dev \
                    libglu1-mesa-dev \
                    freeglut3-dev \
                    mesa-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG DSI_SHA=1685bfeb4df194fa3e907f4ee032691d82aeb3ba
ARG TIPL_SHA=b01ec5a46bdec7d13506d23e97b91fd0840c2b09
RUN mkdir /opt/dsi-studio \
  && cd /opt/dsi-studio \
  && curl -sSLO https://github.com/frankyeh/DSI-Studio/archive/${DSI_SHA}.zip \
  && unzip ${DSI_SHA}.zip \
  && mv DSI-Studio-${DSI_SHA} src \
  && rm -rf ${DSI_SHA}.zip \
  && curl -sSLO https://github.com/frankyeh/TIPL/archive/${TIPL_SHA}.zip \
  && unzip ${TIPL_SHA}.zip \
  && mv TIPL-${TIPL_SHA} src/tipl \
  && rm ${TIPL_SHA}.zip \
  && mkdir build && cd build \
  && qmake ../src && make \
  && cd /opt/dsi-studio \
  && curl -sSLO 'https://www.dropbox.com/s/ew3rv0jrqqny2dq/dsi_studio_64.zip?dl=1' > dsistudio64.zip \
  && mv 'dsi_studio_64.zip?dl=1' dsistudio64.zip \
  && unzip dsistudio64.zip && cd dsi_studio_64 \
  && find . -name '*.dll' -exec rm {} \; \
  && rm -rf iconengines imageformats platforms printsupport \
  && rm dsi_studio.exe \
  && mv ../build/dsi_studio . \
  && rm -rf /opt/dsi-studio/src /opt/dsi-studio/build

# Install mrtrix3 from source
ARG MRTRIX_SHA=5d6b3a6ffc6ee651151779539c8fd1e2e03fad81
ENV PATH="/opt/mrtrix3-latest/bin:$PATH"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           g++ \
           gcc \
           libeigen3-dev \
           libqt5svg5* \
           make \
           python \
           python-numpy \
           zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && cd /opt \
    && curl -sSLO https://github.com/MRtrix3/mrtrix3/archive/${MRTRIX_SHA}.zip \
    && unzip ${MRTRIX_SHA}.zip \
    && mv mrtrix3-${MRTRIX_SHA} /opt/mrtrix3-latest \
    && rm ${MRTRIX_SHA}.zip \
    && cd /opt/mrtrix3-latest \
    && ./configure \
    && echo "Compiling MRtrix3 ..." \
    && ./build

# Installing ANTs latest from source
ARG ANTS_SHA=51855944553a73960662d3e4f7c1326e584b23b2
ADD https://cmake.org/files/v3.11/cmake-3.11.4-Linux-x86_64.sh /cmake-3.11.4-Linux-x86_64.sh
ENV ANTSPATH="/opt/ants-latest/bin" \
    PATH="/opt/ants-latest/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/ants-latest/lib:$LD_LIBRARY_PATH"
RUN mkdir /opt/cmake \
  && sh /cmake-3.11.4-Linux-x86_64.sh --prefix=/opt/cmake --skip-license \
  && ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake \
  && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           g++ \
           gcc \
           make \
           zlib1g-dev \
           imagemagick \
    && mkdir /tmp/ants \
    && cd /tmp \
    && curl -sSLO https://github.com/ANTsX/ANTs/archive/${ANTS_SHA}.zip \
    && unzip ${ANTS_SHA}.zip \
    && mv ANTs-${ANTS_SHA} /tmp/ants/source \
    && rm ${ANTS_SHA}.zip \
    && mkdir -p /tmp/ants/build \
    && cd /tmp/ants/build \
    && git config --global url."https://".insteadOf git:// \
    && cmake -DBUILD_SHARED_LIBS=ON /tmp/ants/source \
    && make -j1 \
    && mkdir -p /opt/ants-latest \
    && mv bin lib /opt/ants-latest/ \
    && mv /tmp/ants/source/Scripts/* /opt/ants-latest/bin \
    && rm -rf /tmp/ants \
    && rm -rf /opt/cmake /usr/local/bin/cmake

ENV C3DPATH="/opt/convert3d-nightly" \
    PATH="/opt/convert3d-nightly/bin:$PATH"
RUN echo "Downloading Convert3D ..." \
    && mkdir -p /opt/convert3d-nightly \
    && curl -fsSL --retry 5 https://sourceforge.net/projects/c3d/files/c3d/Nightly/c3d-nightly-Linux-x86_64.tar.gz/download \
    | tar -xz -C /opt/convert3d-nightly --strip-components 1

# Installing SVGO
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g svgo

# Installing precomputed python packages
RUN conda install -y mkl=2019.1 mkl-service;  sync &&\
    conda install -y numpy=1.15.4 \
                     scipy=1.2.0 \
                     scikit-learn=0.20.2 \
                     matplotlib=3.0.2 \
                     pandas=0.24.0 \
                     libxml2=2.9.9 \
                     libxslt=1.1.33 \
                     graphviz=2.40.1 \
                     cython=0.29.2 \
                     imageio=2.5.0 \
                     olefile=0.46 \
                     pillow=6.0.0 \
                     scikit-image=0.14.2 \
                     traits=4.6.0; sync &&  \
    chmod -R a+rX /usr/local/miniconda; sync && \
    chmod +x /usr/local/miniconda/bin/*; sync && \
    conda clean --all -y; sync && \
    conda clean -tipsy && sync

# Precaching fonts, set 'Agg' as default backend for matplotlib
RUN python -c "from matplotlib import font_manager" && \
    sed -i 's/\(backend *: \).*$/\1Agg/g' $( python -c "import matplotlib; print(matplotlib.matplotlib_fname())" )

# Install latest pandoc
RUN curl -o pandoc-2.2.2.1-1-amd64.deb -sSL "https://github.com/jgm/pandoc/releases/download/2.2.2.1/pandoc-2.2.2.1-1-amd64.deb" && \
    dpkg -i pandoc-2.2.2.1-1-amd64.deb && \
    rm pandoc-2.2.2.1-1-amd64.deb

# Unless otherwise specified each process should only use one thread - nipype
# will handle parallelization
ENV MKL_NUM_THREADS=1 \
    OMP_NUM_THREADS=1

WORKDIR /root/

ENV QSIRECON_ATLAS /atlas/qsirecon_atlases
RUN bash -c \
    'mkdir /atlas \
    && cd  /atlas \
    && wget -nv https://upenn.box.com/shared/static/pvttd0om8zhzfjr7ul6uiny24gmz7ns2.xz \
    && tar xvfJm pvttd0om8zhzfjr7ul6uiny24gmz7ns2.xz \
    && rm pvttd0om8zhzfjr7ul6uiny24gmz7ns2.xz'


# Precaching atlases
ENV CRN_SHARED_DATA /niworkflows_data
ADD get_templates.sh get_templates.sh
RUN mkdir $CRN_SHARED_DATA && \
    /root/get_templates.sh && \
    chmod -R a+rX $CRN_SHARED_DATA && \
    echo "add OASIS30"

# Installing dev requirements (packages that are not in pypi)
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt && \
    rm -rf ~/.cache/pip \
    && echo 1

# Installing qsiprep
#COPY . /root/src/qsiprep
WORKDIR /root/src
RUN git clone https://github.com/PennBBL/qsiprep.git
ARG VERSION
# Force static versioning within container
RUN echo "${VERSION}" > /root/src/qsiprep/qsiprep/VERSION && \
    cd /root/src/qsiprep && \
    pip install .[all] && \
    rm -rf ~/.cache/pip

ENV AFNI_INSTALLDIR=/usr/lib/afni \
    PATH=${PATH}:/usr/lib/afni/bin \
    AFNI_PLUGINPATH=/usr/lib/afni/plugins \
    AFNI_MODELPATH=/usr/lib/afni/models \
    AFNI_TTATLAS_DATASET=/usr/share/afni/atlases \
    AFNI_IMSAVE_WARNINGS=NO \
    FSLOUTPUTTYPE=NIFTI_GZ


RUN ldconfig
WORKDIR /tmp/
#ENTRYPOINT ["/usr/local/miniconda/bin/qsiprep"]

# Expose port for jupyterlab
EXPOSE 8888

# Set working dir
WORKDIR $GIGANTUM_WORKDIR

# CMD may be updated during final image assembly, but this keeps a container alive.
CMD ["tail -f /dev/null"]
