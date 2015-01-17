#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/include/common.sh
source ${CONFIG_PATH}

function Usage()
{
    cat <<-__EOF__
Usage: install_later <package> <install later script>

Sets up a package to be installed later in a given root file system.
This consists of downloading the package, and building up a "install later" script.

Both arguments are neccessary.
__EOF__
}

package=$1
install_later_path=$2

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

DoEcho "Caching ${package}"
CachePackage "${package}"
if [ "$?" -ne 0 ]
then
    DoEcho "Package install failed, does it exist?"
    exit 1
fi

if [ ! -f "${install_later_path}" ]
then
    DoEcho "Initializing install later script"
    cat << '__EOF__' > ${install_later_path}
#!/bin/bash

state_path=/var/lib/install-later
has_ran_path=${state_path}/has_ran

mkdir -p ${state_path}

if [ -f "${has_ran_path}" ]
then
    echo "Install later has ran already"
    exit 0
fi

echo "Install later script starting..."

__EOF__
else
    DoEcho "Adding to install later script"
    sed -i '$ d' "${install_later_path}"
fi

cat << __EOF__ >> ${install_later_path}
echo "Installing ${package}"
apt-get install ${package}

__EOF__

cat << '__EOF__' >> ${install_later_path}
touch ${has_ran_path}
__EOF__

