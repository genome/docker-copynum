FROM ubuntu:xenial
MAINTAINER Megan Neveau <mnneveau@wustl.edu>

LABEL \
    description="Image for copy number workflow"

RUN apt-get update -y && apt-get install -y \
    wget \
    git \
    unzip \
    bzip2 \ 
    g++ \ 
    make \
    zlib1g-dev \
    ncurses-dev \ 
    python \
    default-jdk \
    default-jre \
    libncurses5-dev

###############
#Varscan 2.4.2#
###############
ENV VARSCAN_INSTALL_DIR=/opt/varscan

WORKDIR $VARSCAN_INSTALL_DIR
RUN wget https://github.com/dkoboldt/varscan/releases/download/2.4.2/VarScan.v2.4.2.jar && \
    ln -s VarScan.v2.4.2.jar VarScan.jar

#Don't think I need 
#COPY intervals_to_bed.pl /usr/bin/intervals_to_bed.pl
#COPY varscan_helper.sh /usr/bin/varscan_helper.sh

##############
#HTSlib 1.3.2#
##############
ENV HTSLIB_INSTALL_DIR=/opt/htslib

WORKDIR /tmp
RUN wget https://github.com/samtools/htslib/releases/download/1.3.2/htslib-1.3.2.tar.bz2 && \
    tar --bzip2 -xvf htslib-1.3.2.tar.bz2 && \
    cd /tmp/htslib-1.3.2 && \
    ./configure  --enable-plugins --prefix=$HTSLIB_INSTALL_DIR && \
    make && \
    make install && \
    cp $HTSLIB_INSTALL_DIR/lib/libhts.so* /usr/lib/ && \
ln -s $HTSLIB_INSTALL_DIR/bin/tabix /usr/bin/tabix

################
#Samtools 1.3.1#
################
ENV SAMTOOLS_INSTALL_DIR=/opt/samtools

WORKDIR /tmp
RUN wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 && \
    tar --bzip2 -xf samtools-1.3.1.tar.bz2

WORKDIR /tmp/samtools-1.3.1
RUN ./configure --with-htslib=$HTSLIB_INSTALL_DIR --prefix=$SAMTOOLS_INSTALL_DIR && \
    make && \
    make install

WORKDIR /
RUN rm -rf /tmp/samtools-1.3.1

##add to top
RUN apt-get update -y && apt-get install -y python-pip

######
#Toil#
######
RUN pip install toil[cwl]==3.6.0
RUN sed -i 's/select\[type==X86_64 && mem/select[mem/' /usr/local/lib/python2.7/dist-packages/toil/batchSystems/lsf.py

RUN apt-get update -y && apt-get install -y libnss-sss tzdata
RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

#LSF: Java bug that need to change the /etc/timezone.
#     The above /etc/localtime is not enough.
RUN echo "America/Chicago" > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

###
#R#
###

RUN apt-get update && apt-get install -y r-base littler

ADD rpackage.R /tmp/
RUN R -f /tmp/rpackage.R