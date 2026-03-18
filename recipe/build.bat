@echo off
setlocal enabledelayedexpansion

cd /d "%SRC_DIR%"

rem Patch out the PHP SDK binary tools version check - we don't use the PHP SDK
sed -i "s/if (BIN_TOOLS_SDK_VER_MAJOR < 2)/if (false)/" win32\build\confutils.js

call buildconf.bat --force
if errorlevel 1 exit /b 1

call configure.bat ^
    --prefix="%LIBRARY_PREFIX%" ^
    --with-prefix="%LIBRARY_PREFIX%" ^
    --with-php-build="%LIBRARY_PREFIX%" ^
    --with-openssl ^
    --with-libxml ^
    --with-xsl ^
    --with-curl ^
    --with-bz2 ^
    --with-gmp ^
    --with-sodium ^
    --with-zip ^
    --with-zlib ^
    --with-pgsql ^
    --with-pdo-pgsql ^
    --with-sqlite3 ^
    --with-pdo-sqlite ^
    --with-iconv ^
    --enable-intl ^
    --enable-bcmath ^
    --enable-calendar ^
    --enable-exif ^
    --enable-ftp ^
    --enable-mbstring ^
    --enable-shmop ^
    --enable-soap ^
    --enable-sockets
if errorlevel 1 exit /b 1

nmake /nologo
if errorlevel 1 exit /b 1

nmake /nologo install
if errorlevel 1 exit /b 1
