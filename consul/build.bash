#!/bin/bash

VERSION=$1
APP=consul
: ${CONSUL_RELEASE_URL:="https://releases.hashicorp.com/${APP}"}
: ${ARCH:="linux_amd64"}
: ${CONSUL_INSTALL:=/usr/local/bin/}

function __wrap_and_fail() {
    $*
    if [[ $? != 0 ]]; then
        echo -e "$* failed. \nExiting"
        exit
    fi
}

if [[ -z $VERSION ]]; then
    echo "Usage: builder.bash VERSION [ARCH]"
    exit 1
fi

if [[ -z $ARCH ]]; then
    echo "ARCH is empty. Exiting"
    exit 1
fi

SHASUMS="${APP}_${VERSION}_SHA256SUMS"

echo "Fetching and importing hashicorp's gpg key from keybase"
echo "See https://www.hashicorp.com/security.html for more information"
sleep 1
# curl + gpg pro tip: import hashicorp's keys
__wrap_and_fail curl -fs https://keybase.io/hashicorp/pgp_keys.asc | gpg --import

echo "Fetching SHA256SUMS"
__wrap_and_fail curl -Ofs "${CONSUL_RELEASE_URL}/${VERSION}/${SHASUMS}"
echo "Fetching SHA256SUMS signatures"
__wrap_and_fail curl -Ofs "${CONSUL_RELEASE_URL}/${VERSION}/${SHASUMS}.sig"
echo "Fetching ${APP}_${VERSION}_${ARCH}.zip"

__wrap_and_fail curl -Ofs "${CONSUL_RELEASE_URL}/${VERSION}/${APP}_${VERSION}_${ARCH}.zip"

echo "Checking gpg signature for ${APP}"
__wrap_and_fail gpg --verify "${SHASUMS}.sig" $SHASUMS

# We only downloaded 1 file so we're going to ignore missing files
echo "Checking hash of ${APP} archive"
__wrap_and_fail sha256sum -c --ignore-missing $SHASUMS

unzip -o "${APP}_${VERSION}_${ARCH}.zip"
rm "${SHASUMS}.sig" $SHASUMS "${APP}_${VERSION}_${ARCH}.zip"
gpg --delete-key --batch --yes "Hashicorp Security"

case $ARCH in
    "linux_amd64")
        package_arch="x64_86"
esac

if [[ -z $package_arch ]]; then
    echo "$ARCH does not map to something we can package. Exiting"
    exit 1
fi

fpm -t rpm -s dir -f --prefix $CONSUL_INSTALL -n consul -v $VERSION --url "https://www/consul.io" consul
rm consul
