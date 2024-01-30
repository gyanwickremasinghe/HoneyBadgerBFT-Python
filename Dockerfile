FROM python:3.7-stretch
FROM debian:bullseye-slim

# Default cluster arguments. Override with "-e"
#
# total number of parties:
ENV N 8
# tolerance, usually N/4 in our experiments:
ENV t 2
# maximum number of transactions committed in a block:
ENV B 16

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bison \
    flex \
    libgmp-dev \
    libmpc-dev && \
    rm -rf /var/lib/apt/lists/*
    
RUN apt-get update && apt-get -y install wget make
    
RUN wget https://crypto.stanford.edu/pbc/files/pbc-0.5.14.tar.gz
RUN tar -xvf pbc-0.5.14.tar.gz
RUN cd pbc-0.5.14 && ./configure && make && make install

ENV LIBRARY_PATH /usr/local/lib
ENV LD_LIBRARY_PATH /usr/local/lib

RUN apt-get update && apt-get -y install git
RUN apt-get update && apt-get -y install python3 python3-pip
RUN pip3 install gevent setuptools gevent numpy ecdsa pysocks gmpy2 zfec gipc pycryptodemo coincurve

RUN git clone https://github.com/JHUISI/charm.git
RUN cd charm && ./configure.sh && make install

ENV SRC /usr/local/src/HoneyBadgerBFT
WORKDIR $SRC
ADD . $SRC/

RUN pip install --upgrade pip
RUN pip install -e .[dev]

# Run tests by default
CMD sh test.sh
