#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/include/common.sh

ParseCommonArgs "${@}"

DoEcho "Installing dpkg-dev"
InstallPackage "dpkg-dev"

if [[ "x${CONFIG_SIGN_REPOSITORY}" != "xyes" ]]
then
    exit 0
fi

DoEcho "Installing rng-tools"
InstallPackage "rng-tools"

DoEcho "Seeding rng"
/usr/sbin/rngd -r /dev/urandom

cat >"${CONFIG_GPG_KEYS_PATH}/setup" <<EOF
%echo Generating a default key
Key-Type: 1
Key-Length: 2048
Subkey-Type: 1
Subkey-Length: 2048
Name-Real: ${CONFIG_GPG_KEY_NAME}
Expire-Date: 0
EOF

DoEcho "Setting up gpg-keys in ${CONFIG_GPG_KEYS_PATH}"
mkdir -p "${CONFIG_GPG_KEYS_PATH}"
gpg --batch --gen-key "${CONFIG_GPG_KEYS_PATH}/setup"
gpg -a --export-secret-key ${CONFIG_GPG_KEY_NAME} > "${CONFIG_GPG_KEYS_PATH}/secret.gpg"
gpg -a --export ${CONFIG_GPG_KEY_NAME} > "${CONFIG_GPG_KEYS_PATH}/public.gpg"

DoEcho "Importing generated keys"
gpg --import -v -v "${CONFIG_GPG_KEYS_PATH}/secret.gpg"
gpg --import -v -v "${CONFIG_GPG_KEYS_PATH}/public.gpg"
