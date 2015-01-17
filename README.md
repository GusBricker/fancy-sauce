# Fancy Sauce
=========================================================

Fancy sauce is a set of helper scripts for managing and deploying root file systems.


## Features
---------------------------------------------------------

- Build installed packages manifest using dpkg.
- Setup local apt repository for quick rootfs rebuilding.
- Deferred package installation using apt.


### build_installed_manifest.sh
---------------------------------------------------------

Calling build_installed_manifest.sh will use dpkg -l to list installed packages and write the output to a file specified by `${CONFIG_OUTPUT_MANIFEST_PATH}` in CONFIG.sh.

This script depends on a filled out CONFIG.sh sitting beside this script.
Follow the provided sample for tips.


### download_package.sh
---------------------------------------------------------

This script expects a manifest file specified by `${CONFIG_INPUT_MANIFEST_PATH}`in CONFIG.sh.
It will setup a repo based on CONFIG.sh fields then populate it with packages and their source if specified.

This repo can then be given to apt like this:

``` bash
deb file://${CONFIG_DOWNLOAD_PACKAGES_PATH} ${CONFIG_RELEASE_NAME} ${CONFIG_PACKAGES_SECTION_NAME}
deb-src file://${CONFIG_DOWNLOAD_PACKAGES_PATH} ${CONFIG_RELEASE_NAME} ${CONFIG_PACKAGES_SECTION_NAME}
```

This script depends on the prereqs.sh script being ran beforehand and a filled out CONFIG.sh sitting beside this script.
Follow the provided sample for tips.


### install_later.sh
---------------------------------------------------------

This is a standalone script that sets up a package to be installed later.
Which involves telling apt to cache the package using `apt-get -d install ${package}`
Cached packages are stored in /var/cache/apt/archives.

Each call to install_later also sets up a install later script at a given path.
An install later script is a simple bash script which has lots of apt-get install calls and
can only run once. Running once is controlled by a state variable saved at /var/lib/install-later/has_run.

This script does not depend on CONFIG.sh
