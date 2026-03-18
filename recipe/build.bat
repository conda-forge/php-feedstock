@echo off
setlocal enabledelayedexpansion

cd /d "%SRC_DIR%"

rem Create phpsdk_version shim to satisfy PHP's SDK version check
echo @echo PHP SDK 2.3.0 > "%SRC_DIR%\phpsdk_version.bat"
set "PATH=%SRC_DIR%;%PATH%"

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
