# use the ubuntu base image
FROM ubuntu:18.04

MAINTAINER Tobias Rausch rausch@embl.de / Ilya Soifer ilya.soifer@ultimagen.com

# install required packages
RUN apt-get update && apt-get install -y \
    autoconf \
    build-essential \
    cmake \
    g++ \
    gfortran \
    git \
    libcurl4-gnutls-dev \
    hdf5-tools \
    libboost-date-time-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-iostreams-dev \
    libbz2-dev \
    libhdf5-dev \
    libncurses-dev \
    liblzma-dev \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# set environment
ENV BOOST_ROOT /usr

# Copy deploy key, saved in ilya-ubuntu-vm in ~/dockers/
# The docker file should be launching from there only
ADD delly2-repo-key /
RUN \
  chmod 600 /delly2-repo-key && \  
  echo "IdentityFile /delly2-repo-key" >> /etc/ssh/ssh_config && \  
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config   

# install delly
RUN cd /opt \
    && git clone --recursive git@github.com:Ultimagen/delly-private.git delly \
    && cd /opt/delly/ \
    && make STATIC=1 all \
    && make install


# Multi-stage build
FROM alpine:latest
RUN mkdir -p /opt/delly/bin
WORKDIR /opt/delly/bin
COPY --from=0 /opt/delly/bin/delly .

RUN apk add --no-cache --upgrade bash

# Workdir
WORKDIR /root/

# Add Delly to PATH
ENV PATH="/opt/delly/bin:${PATH}"

# by default /bin/sh is executed
CMD ["/bin/sh"]
