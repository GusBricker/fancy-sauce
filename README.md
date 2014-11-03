Fancy Sauce
=========================================================

These scripts are still a work in progress, but they do currently work. The idea of Fancy Sauce is to download all the packages some Debian system currently has installed and create a local repository for quick re-setup.

Usage
---------------------------------------------------------

- Copy the CONFIG.sh.template and fill it in.
- Run build_installed_manifest.sh
    ./build_installed_manifest.sh
- Run download_packages.sh
    ./download_packages.sh
- Use your pretty new local repository, point to ${CONFIG_DOWNLOAD_PACKAGES_PATH}
