# Copyright (c) Gigantum

# Note, some docker commands taken from/inspired by the standard docker-stacks maintained
# by the Jupyter team: https://github.com/jupyter/docker-stacks/
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

FROM ubuntu:18.04
LABEL maintainer="Gigantum <hello@gigantum.io>"

# Install system level dependencies
RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    gcc \
    g++ \
    make \
    sudo \
    locales \
    fonts-liberation \
    gosu \
    git && \
    apt-get clean 

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Setup environment variables
ENV CONDA_DIR=/opt/conda \
    GIGANTUM_SHARE=/mnt/share \
    GIGANTUM_WORKDIR=/mnt/labbook \
    SHELL=/bin/bash \
    MINICONDA_VERSION=4.3.31 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    JUPYTER_RUNTIME_DIR=$GIGANTUM_SHARE/jupyter/runtime

# Install conda and python
RUN cd /tmp && wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "7fe70b214bee1143e3e3f0467b71453c *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda update --all --quiet --yes

# Install and configure JupyterLab
RUN conda install --quiet --yes -c conda-forge \
    'jupyterlab=0.31.*' \
    'notebook=5.3.*' && \ 
    conda create -n ipykernel_py2 python=2 ipykernel && \
    /opt/conda/envs/ipykernel_py2/bin/python -m ipykernel install && \
    conda clean -tipsy && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging \ 
EXPOSE 8888

# make pip2 and conda2 address the py2 virtualenv ipykernel_py2
# remove python3 kernel.  rename pip and conda to pip3 and conda3.  
# add a white list in giguser to suppress the python3 kernel.
RUN mv /opt/conda/bin/pip /opt/conda/bin/pip3 && \
    mv /opt/conda/bin/conda /opt/conda/bin/conda3 && \
    ln /opt/conda/envs/ipykernel_py2/bin/pip /opt/conda/bin/pip && \
    echo "c.KernelSpecManager.whitelist = {'python2'}" > /opt/conda/etc/jupyter/jupyter_notebook_config.py && \
    chmod 0644 /opt/conda/etc/jupyter/jupyter_notebook_config.py
COPY conda2script.bash /opt/conda/bin/conda
RUN chmod a+rx /opt/conda/bin/conda

# Set working dir
WORKDIR $GIGANTUM_WORKDIR

# CMD may be updated during final image assembly, but this keeps a container alive.
CMD ["tail -f /dev/null"]
