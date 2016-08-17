#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/include/common.sh

ParseCommonArgs "${@}"

DoEcho "Listing installed packages"
installed_packages=$(dpkg -l | grep ^ii)

DoEcho "Making sure directories exist"
mkdir -p $(dirname ${CONFIG_OUTPUT_MANIFEST_PATH})

DoEcho "Writing manifest file to: ${CONFIG_OUTPUT_MANIFEST_PATH}"
echo "${installed_packages}" > "${CONFIG_OUTPUT_MANIFEST_PATH}"

