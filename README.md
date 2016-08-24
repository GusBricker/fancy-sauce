# Fancy Sauce

Fancy sauce is a set of helper scripts for managing and deploying root file systems.


### Features
---------------------------------------------------------

- Build installed packages manifest using dpkg.
- Setup local signed apt repository for quick rootfs rebuilding.
- Deferred package installation using apt.


### build_installed_manifest <config file>
---------------------------------------------------------

Calling build_installed_manifest.sh will use `dpkg -l` to list installed packages and write the output to a file specified by
`${CONFIG_MANIFEST_PATH}`.


### setup_gpg_key <config file>
---------------------------------------------------------

This is a simple helper script to assist in setting up your GPG key to sign any custom packages.

It will setup the GPG key based on the `${CONFIG_GPG_KEY}` setting. These options are documented at: https://www.gnupg.org/documentation/manpage.html


### generate_repository <config file>
---------------------------------------------------------

This script expects a manifest file to exist at `${CONFIG_MANIFEST_PATH}`. The script will then proceed to download all the packages specified into
the `${CONFIG_DOWNLOAD_PACKAGES_PATH}` directory and then add it to the repository using reprepro.

Custom packages can also be added to the repoistory using the `${CONFIG_CUSTOM_PACKAGES_PATH}` variable.

It will setup the apt repository based `${CONFIG_DISTRIBUTIONS}` setting. These options are documented at: https://mirrorer.alioth.debian.org/reprepro.1.html


### install_later
---------------------------------------------------------

This is a standalone script that sets up a package to be installed later.
Which involves telling apt to cache the package using `apt-get -d install ${package}`.
Cached packages are stored in `/var/cache/apt/archives`.

Each call to install_later also sets up a install later script at a given path.
An install later script is a simple bash script which has lots of apt-get install calls and
can only run once. Running once is controlled by a state variable saved at `/var/lib/install-later/has_run`.
