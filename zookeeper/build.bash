#!/bin/bash
set -x
VERSION=${1:-3.4.10}
OUTPUT="zookeeper-${VERSION}"
MIRROR="http://mirror.cc.columbia.edu/pub/software/apache/zookeeper/zookeeper-${VERSION}/zookeeper-${VERSION}.tar.gz"

BUILD=/data/build
DIST=/data/dist
mkdir -p $BUILD
mkdir -p $DIST

cd $BUILD
wget $MIRROR -O zookeeper.tar.gz
tar -xvf zookeeper.tar.gz
cd zookeeper-$VERSION
SHA=$(sha1sum "zookeeper-${VERSION}.jar"|cut -f1 -d' ')
if [[ $SHA != $(cat "zookeeper-${VERSION}.jar.sha1") ]]; then
    echo "zookeeper jar sha1 doesn't match packaged sha1"
    exit 1
fi

cd $DIST

fpm -s dir -t rpm -C "${BUILD}/zookeeper-${VERSION}" --name zookeeper --version $VERSION --prefix /var/lib/zookeeper bin contrib lib "zookeeper-${VERSION}.jar"
rm -rf $BUILD
