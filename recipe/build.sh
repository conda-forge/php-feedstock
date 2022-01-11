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

bash -c "NO_INTERACTION=1; make test"

make install
