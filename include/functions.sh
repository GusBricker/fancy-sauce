#!/bin/bash

function DoEcho()
{
    echo "=== $1"
}

function PackageName()
{
    local package=$1
    local version=$2

    apt-cache show ${package}=${version} | grep "Filename:" | sed 's/.*\///'
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
    local version=$2

    if [ "x${version}" == "x" ]
    then
        arg="${package}"
    else
        arg="${package}=${version}"
    fi

    apt-get -d install ${arg}
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
    local package=$1
    local version=$2

    if [[ "x${version}" == "x" ]]
    then
        apt-get install -y "${package}"
    else
        apt-get install -y "${package}"="${version}"
    fi

}

function RelToAbsPath()
{
    local rel=$1
    
    abs=$(readlink -f "${rel}")

    echo "${abs}"
}
