#!/bin/bash

set -ex

# remove test failing in non interactive shell
rm ext/standard/tests/file/lstat_stat_variation10.phpt
rm ext/standard/tests/network/bug73594.phpt

./configure --prefix=$PREFIX \
            --with-iconv=$PREFIX \
            --with-openssl=$PREFIX \
            --with-libxml-dir=$PREFIX \
            --with-external-pcre

make -j${CPU_COUNT}

export NO_INTERACTION=1
if [[ "${target_platform}" == "linux-"* ]]; then
    script -ec "make test"
else
    export SKIP_IO_CAPTURE_TESTS=1
    make test
fi

make install
