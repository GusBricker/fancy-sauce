#!/bin/bash

function DoEcho()
{
    echo "=== $@"
}

function ContinueEcho()
{
    echo "      $@"
}

function PackageName()
{
    local package=$1
    local version=$2

    local line=$(apt-get download -o Debug::NoLocking=1 --print-uris ${package}=${version} | cut -d' ' -f2)
    local result=$?

    echo "${line}"
    return ${result}
}

function PackageSourceName()
{
    local package=$1
    local version=$2
    local lines=($(apt-get source -o Debug::NoLocking=1 --print-uris ${package}=${version} | grep "${package}" | cut -d' ' -f2))
    local line=""

    for line in "${lines[@]}"
    do
        if [[ "${line}" == *".dsc" ]]
        then
            echo "${line}"
            return 0
        fi
    done

    return 1
}

function PackageSHA256()
{
    local package=$1
    local version=$2

    apt-cache show ${package}=${version} | grep "SHA256:" | cut -f 2 -d " "
}

function CalculateSHA256()
{
    local filename=$1

    sha256sum "${filename}" | cut -f 1 -d " "
}

function DownloadPackage()
{
    local package=$1
    local version=$2
    local location=$3

    apt-get -d -o=dir::cache="${location}" -o Debug::NoLocking=1 download ${package}=${version}
}

function CachePackage()
{
    local package=$1
    local download_directory=$2

    apt-get --print-uris --yes install "${package}" | grep ^\' | cut -d\' -f2 | xargs wget -P "${download_directory}"
}


function DownloadPackageSource()
{
    local package=$1
    local version=$2
    local location=$3

    apt-get -o=dir::cache="${location}" -o Debug::NoLocking=1 source ${package}=${version}

}

function InstallPackage()
{
    apt-get install -y "${@}"
}

function RelToAbsPath()
{
    local rel=$1
    
    abs=$(readlink -f "${rel}")

    echo "${abs}"
}

function ParseCommonArgs()
{
    if [[ "x${1}" == "x" ]]
    then
        DoEcho "Missing 1st (and only!) argument: path to config file"
        exit 1
    fi

    if [ ! -f "${1}" ]
    then
        DoEcho "Config file path isn't correct"
        exit 1
    fi

    source ${1}
}

function pushd()
{
    command pushd "$@" > /dev/null
}

function popd()
{
    command popd "$@" > /dev/null
}
