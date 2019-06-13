FROM ubuntu:18.04

LABEL maintainer="katsuta <katsuta@jnlp.org>"

RUN apt update && apt upgrade -y && apt install -y g++ git subversion automake libtool zlib1g-dev libboost-all-dev libbz2-dev liblzma-dev python-dev graphviz imagemagick make cmake libgoogle-perftools-dev autoconf doxygen libsparsehash-dev build-essential pkg-config wget libsoap-lite-perl  python3-pip

RUN pip3 install numpy https://download.pytorch.org/whl/cpu/torch-1.1.0-cp36-cp36m-linux_x86_64.whl torchvision

# XML-RPC
WORKDIR /smt_dip
RUN wget http://www.achrafothman.net/aslsmt/tools/xmlrpc-c_1.33.14.orig.tar.gz
RUN tar zxvf xmlrpc-c_1.33.14.orig.tar.gz
WORKDIR  /smt_dip/xmlrpc-c-1.33.14
RUN ./configure
RUN make && make install

#cmph-2.0
WORKDIR /smt_dip
RUN wget http://www.achrafothman.net/aslsmt/tools/cmph_2.0.orig.tar.gz
RUN tar zxvf cmph_2.0.orig.tar.gz
WORKDIR /smt_dip/cmph-2.0
RUN ./configure
RUN make && make install

#SALM
WORKDIR /smt_dip
RUN git clone https://github.com/moses-smt/salm.git
WORKDIR /smt_dip/salm/Distribution/Linux
RUN make allO64

# moses
WORKDIR /opt
RUN git clone https://github.com/artetxem/monoses.git
WORKDIR /opt/monoses
RUN ./get-third-party.sh

#compile fast_align
WORKDIR /opt/monoses/third-party/fast_align
RUN mkdir build
WORKDIR /opt/monoses/third-party/fast_align/build
RUN cmake .. && make

#compile phrase2vec
WORKDIR /opt/monoses/third-party/phrase2vec
RUN make

#compile moses
WORKDIR /opt/monoses/third-party/moses
RUN ./bjam --with-cmph=/smt_dip/cmph-2.0 --with-xmlprc-c=/usr/local

WORKDIR /opt/monoses/third-party/moses/contrib/sigtest-filter
RUN make SALMDIR=/smt_dip/salm

WORKDIR /opt/monoses

