#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/include/common.sh
source ${CONFIG_PATH}

function Usage()
{
    cat <<-__EOF__
Usage: install_later <package> <install later script> <cache directory>

Sets up a package to be installed later in a given root file system.
This consists of downloading the package, and building up a "install later" script.

Both arguments are neccessary.
__EOF__
}

package="$1"
install_later_path="$2"
cache_path="$3"

if [ "x${package}" == "x" ]
then
    DoEcho "Missing package, stopping"
    Usage
    exit 1
fi

if [ "x${install_later_path}" == "x" ]
then
    DoEcho "Missing install later script path, stopping"
    Usage
    exit 1
fi

if [ "x${cache_path}" == "x" ]
then
    DoEcho "Missing cache path, stopping"
    Usage
    exit 1
fi

mkdir -p "${cache_path}"
DoEcho "Caching ${package}"
CachePackage "${package}" "${cache_path}"
if [ "$?" -ne 0 ]
then
    DoEcho "Package install failed, does it exist?"
    exit 1
fi

apt-get update -y --force-yes

if [ ! -f "${install_later_path}" ]
then
    DoEcho "Initializing install later script"
    cat << '__EOF__' > ${install_later_path}
#!/bin/bash

state_path=/var/lib/install-later
log_file=/var/log/install-later.log
has_ran_path=${state_path}/has_ran

mkdir -p ${state_path}

if [ -f "${has_ran_path}" ]
then
    echo "Install later has ran already"
    exit 0
fi

exec >  >(tee -a ${log_file})
exec 2> >(tee -a ${log_file} >&2)

set -e

echo "Install later script starting..."

__EOF__

    cat << __EOF__ >> ${install_later_path}
cache_path=${cache_path}

find \${cache_path}/*.deb  -printf "Installing %f\n"
dpkg -i \${cache_path}/*.deb

__EOF__

    cat << '__EOF__' >> ${install_later_path}
if [ $? -ne 0 ]
then
    echo "Installation failed!"
else
    echo "Installation success!"
    rm -r ${cache_path}
    touch ${has_ran_path}
fi
__EOF__
fi


