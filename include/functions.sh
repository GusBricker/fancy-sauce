#!/bin/bash

function DoEcho()
{
    echo "=== $1"
}

function DownloadPackage()
{
    local package=$1
    local version=$2
    local location=$3

    apt-get -d -o=dir::cache="${location}" -o Debug::NoLocking=1 download ${package}=${version}
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
