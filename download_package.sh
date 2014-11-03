#!/bin/bash

DIR=$(dirname "$0")
source ${DIR}/include/common.sh
source ${CONFIG_PATH}

DoEcho "Installing dpkg-dev"
InstallPackage "dpkg-dev"

DoEcho "Reading manifest from: ${CONFIG_INPUT_MANIFEST_PATH}"
IFS=$'\n' read -d '' -r -a LINES < ${CONFIG_INPUT_MANIFEST_PATH}

DoEcho "Making sure directories exist"
base_release_dir="${CONFIG_DOWNLOAD_PACKAGES_PATH}/dists/${CONFIG_RELEASE_NAME}"
section_dir="${base_release_dir}/${CONFIG_PACKAGES_SECTION_NAME}"
binary_release_dir="${section_dir}/binary-${CONFIG_ARCHITECTURE}"
source_release_dir="${section_dir}/source"
mkdir -p "${binary_release_dir}"
mkdir -p "${source_release_dir}"

for line in "${LINES[@]}"; do
    FIELDS=( ${line} )
    pkg="${FIELDS[1]}"
    ver="${FIELDS[2]}"

    pushd "${binary_release_dir}"
    DoEcho "Downloading ${pkg}:${ver}"
    DownloadPackage "${pkg}" "${ver}" "$(pwd)"
    popd

    pushd "${source_release_dir}"
    DoEcho "Downloading source ${pkg}:${ver}"
    DownloadPackageSource "${pkg}" "${ver}" "$(pwd)"
    popd
done

repo_config_file_path="${base_release_dir}/setup"
repo_release_config_file_path="${base_release_dir}/setup-release"
abs_archive_path=$(RelToAbsPath "${CONFIG_DOWNLOAD_PACKAGES_PATH}")
cat >"${repo_config_file_path}" <<EOF
Dir {
    ArchiveDir "${abs_archive_path}";
};
 
BinDirectory "dists/${CONFIG_RELEASE_NAME}" {
    Packages "dists/${CONFIG_RELEASE_NAME}/${CONFIG_PACKAGES_SECTION_NAME}/binary-${CONFIG_ARCHITECTURE}/Packages";
    SrcPackages "dists/${CONFIG_RELEASE_NAME}/${CONFIG_PACKAGES_SECTION_NAME}/source/Sources";
};

Tree "dists/${CONFIG_RELEASE_NAME}" {
    Sections "${CONFIG_PACKAGES_SECTION_NAME}";
    Architectures "${CONFIG_ARCHITECTURE} source";
};
EOF

cat >"${repo_release_config_file_path}" <<EOF
APT::FTPArchive::Release::Origin "Local Repository";
APT::FTPArchive::Release::Label "Your Local Repository";
APT::FTPArchive::Release::Suite "stable";
APT::FTPArchive::Release::Codename "${CONFIG_RELEASE_NAME}";
APT::FTPArchive::Release::Architectures "${CONFIG_ARCHITECTURE} source";
APT::FTPArchive::Release::Components "${CONFIG_PACKAGES_SECTION_NAME}";
APT::FTPArchive::Release::Description "Something here";
EOF

DoEcho "Setting up repo"
apt-ftparchive generate "${repo_config_file_path}"

DoEcho "Setting up repo release"
apt-ftparchive -c "${repo_release_config_file_path}" release "${base_release_dir}" > "${base_release_dir}/Release" 

if [[ "x${CONFIG_SIGN_REPOSITORY}" == "xyes" ]]
then
    DoEcho "Signing repo"
    gpg --yes -abs -u "${CONFIG_GPG_KEY_NAME}" -o "${base_release_dir}/Release.gpg" "${base_release_dir}/Release"
fi

