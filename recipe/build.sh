#!/bin/bash

set -ex

export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH

# PHP's configure uses aarch64, but conda sets arm64 on macOS
if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" ]]; then
    export PHP_BUILD_HOST="aarch64-apple-darwin$(uname -r)"
fi

# remove test failing in non interactive shell
rm ext/standard/tests/file/lstat_stat_variation10.phpt
rm ext/standard/tests/network/bug73594.phpt

# skip flaky test at TravisCI
# https://github.com/php/php-src/blob/b9f4fb8aefaeb3802d6f79f6aad7029b63e488a2/ext/standard/tests/file/disk_free_space_basic.phpt#L5
if [[ "$CI" == "travis" ]]; then
    export TRAVIS="true"
fi

./configure --prefix=$PREFIX \
            ${PHP_BUILD_HOST:+--build=$PHP_BUILD_HOST --host=$PHP_BUILD_HOST} \
            --with-iconv=$PREFIX \
            --with-openssl=$PREFIX \
            --with-external-pcre \
            --with-bz2=$PREFIX \
            --with-curl=$PREFIX \
            --with-gmp=$PREFIX \
            --with-sodium=$PREFIX \
            --with-zip \
            --with-zlib \
            --with-readline=$PREFIX \
            --with-xsl=$PREFIX \
            --with-pgsql=$PREFIX \
            --with-pdo-pgsql=$PREFIX \
            --enable-intl \
            --enable-bcmath \
            --enable-calendar \
            --enable-exif \
            --enable-ftp \
            --enable-mbstring \
            --enable-pcntl \
            --enable-shmop \
            --enable-soap \
            --enable-sockets \
            --enable-sysvmsg \
            --enable-sysvsem \
            --enable-sysvshm

make -j${CPU_COUNT}

export NO_INTERACTION=1
if [[ "${target_platform}" == "linux-"* ]]; then
    script -ec "make test"
else
    export SKIP_IO_CAPTURE_TESTS=1
    make test
fi

make install
