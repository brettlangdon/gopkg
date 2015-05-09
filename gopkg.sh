#!/usr/bin/env bash
GOPKG_ORIGINAL_PS1=${PS1}
GOPKG_ORIGINAL_GOPATH=${GOPATH}

gopkg_verify_env () {
    env=$(printenv ${1})
    if [ -z ${env} ];
    then
        echo '$'${1}' environment variable must be set.' >&2
        return 1
    fi

    return 0
}

gopkg_get_gopath_base () {
    # If we have multiple paths on $GOPATH we want the last one
    paths=$(echo ${GOPATH} | tr ':' '\n')
    go_path=''
    echo $paths | while read p;
    do
        go_path=$p
    done
    echo $go_path
    return 0
}

gopkg_get_pkg_dir () {
    if [ -z $1 ];
    then
        echo 'gopkg_get_pkg_dir requires 1 argument' >&2
        return 1
    fi

    go_path_base=$(gopkg_get_gopath_base)
    echo ${go_path_base%%/}'/src/'${GOPKG_REPO%%/}'/'${1}
    return 0
}

gopkg_get_pkg_home () {
    if [ -z $1 ];
    then
        echo 'gopkg_get_pkg_home requires 1 argument' >&2
        return 1
    fi
    echo ${GOPKG_HOME%%/}'/'${1}
    return 0
}

mkgopkg () {
    if [ -z ${1} ];
    then
        echo 'mkgopkg requires at least 1 argument' >&2
        return 1
    fi

    gopkg_verify_env 'GOPKG_HOME' || return 1
    gopkg_verify_env 'GOPKG_REPO' || return 1
    gopkg_verify_env 'GOPATH'  || return 1

    pkg_home=$(gopkg_get_pkg_home $1)
    pkg_dir=$(gopkg_get_pkg_dir $1)

    if [ -d ${pkg_dir} ] && [ -d ${pkg_home} ];
    then
        echo 'gopkg '${1}' already exists. Activate it with `gopkg '${1}'`' >&2
        return 1
    fi
    echo 'Creating package source: '${pkg_dir}
    mkdir -p $pkg_dir
    echo 'Creating package home: '${pkg_home}
    mkdir -p $pkg_home
    echo 'Package '${1}' created.'
    echo 'Activate with `gopkg '${1}'`'
    return 0
}

rmgopkg () {
    if [ -z ${1} ];
    then
        echo 'rmgopkg requires at least 1 argument' >&2
        return 1
    fi
    gopkg_verify_env 'GOPKG_HOME' || return 1

    pkg_home=$(gopkg_get_pkg_home $1)
    pkg_dir=$(gopkg_get_pkg_dir $1)
    if [ ! -d ${pkg_home} ];
    then
        echo 'gopkg '${1}' does not exist. Not removing anything' >&2
        return 1
    fi

    if [ -d ${pkg_dir} ];
    then
        echo 'Keeping source directory '${pkg_dir}
    fi

    echo 'Removing '${pkg_home}
    rm -rf ${pkg_home}
    return 0
}

gopkg () {
    if [ -z ${1} ];
    then
        echo 'gopkg requires at least 1 argument' >&2
        return 1
    fi
    gopkg_verify_env 'GOPKG_HOME' || return 1

    pkg_home=$(gopkg_get_pkg_home $1)
    if [ ! -d ${pkg_home} ];
    then
        echo 'gopkg '${1}' does not exists, create it first with `mkgopkg '${1}'`' >&2
        return 1
    fi

    go_path_base=$(gopkg_get_gopath_base)
    export GOPATH=${pkg_home}:${go_path_base}
    export PS1='('${1}') '$GOPKG_ORIGINAL_PS1

    eval 'deactivate () {
      export GOPATH=${GOPKG_ORIGINAL_GOPATH}
      export PS1=${GOPKG_ORIGINAL_PS1}
      unset -f deactivate > /dev/null 2>&1
    }'
    echo ${1}' activated. Deactivate with `deactivate`'

    return 0
}
