#!/bin/bash

VERSION=${1:-1.5.0}
OUTPUT="mesos-${VERSION}"
MIRROR="http://mirror.cc.columbia.edu/pub/software/apache/mesos/${VERSION}/mesos-${VERSION}.tar.gz"

DIST=/data/dist
STAGING=/data/staging
BUILD=/data/build

mkdir -p $DIST
mkdir -p $BUILD
mkdir -p $STAGING

cd $BUILD
wget $MIRROR -O mesos.tar.gz
tar -xvf mesos.tar.gz

cd $OUTPUT
./configure --prefix=$STAGING --disable-python --disable-java
make
make install

cd $DIST
fpm -s dir -t rpm --name mesos -C $STAGING --version $VERSION *
rm -rf $STAGING $BUILD
