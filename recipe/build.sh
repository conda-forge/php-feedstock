#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./build

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
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    make test
fi
fi

make install
