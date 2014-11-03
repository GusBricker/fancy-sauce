#!/bin/bash

DIR=$(dirname "$0")
source ${DIR}/include/common.sh
source ${CONFIG_PATH}

DoEcho "Listing installed packages"
installed_packages=$(dpkg -l | grep ^ii)

DoEcho "Making sure directories exist"
mkdir -p $(dirname ${CONFIG_OUTPUT_MANIFEST_PATH})

DoEcho "Writing manifest file to: ${CONFIG_OUTPUT_MANIFEST_PATH}"
echo "${installed_packages}" > "${CONFIG_OUTPUT_MANIFEST_PATH}"

