#!/bin/bash

VERSION=$1
: ${VAULT_RELEASE_URL:="https://releases.hashicorp.com/vault"}
: ${ARCH:="linux_amd64"}
: ${VAULT_INSTALL:=/usr/local/bin/}

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

SHASUMS="vault_${VERSION}_SHA256SUMS"

echo "Fetching and importing hashicorp's gpg key from keybase"
echo "See https://www.hashicorp.com/security.html for more information"
sleep 1
# curl + gpg pro tip: import hashicorp's keys
__wrap_and_fail curl -fs https://keybase.io/hashicorp/pgp_keys.asc | gpg --import

echo "Fetching SHA256SUMS"
__wrap_and_fail curl -Ofs "${VAULT_RELEASE_URL}/${VERSION}/${SHASUMS}"
echo "Fetching SHA256SUMS signatures"
__wrap_and_fail curl -Ofs "${VAULT_RELEASE_URL}/${VERSION}/${SHASUMS}.sig"
echo "Fetching vault_${VERSION}_${ARCH}.zip"
__wrap_and_fail curl -Ofs "${VAULT_RELEASE_URL}/${VERSION}/vault_${VERSION}_${ARCH}.zip"

echo "Checking gpg signature for vault"
__wrap_and_fail gpg --verify "${SHASUMS}.sig" $SHASUMS

# We only downloaded 1 file so we're going to ignore missing files
echo "Checking hash of vault archive"
__wrap_and_fail sha256sum -c --ignore-missing $SHASUMS

unzip -o "vault_${VERSION}_${ARCH}.zip"
rm "${SHASUMS}.sig" $SHASUMS "vault_${VERSION}_${ARCH}.zip"
gpg --delete-key --batch --yes "Hashicorp Security"

case $ARCH in
    "linux_amd64")
        package_arch="x64_86"
esac

if [[ -z $package_arch ]]; then
    echo "$ARCH does not map to something we can package. Exiting"
    exit 1
fi

fpm -t rpm -s dir -f --prefix $VAULT_INSTALL -n vault -v $VERSION --url "https://vaultproject.io" vault
rm vault
