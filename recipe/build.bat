@echo off
setlocal enabledelayedexpansion

cd /d "%SRC_DIR%"

rem Patch out the PHP SDK binary tools version check - we don't use the PHP SDK
sed -i "s/if (BIN_TOOLS_SDK_VER_MAJOR < 2)/if (false)/" win32\build\confutils.js

call buildconf.bat --force
if errorlevel 1 exit /b 1

call configure.bat ^
    --with-prefix="%LIBRARY_PREFIX%" ^
    --with-php-build="%LIBRARY_PREFIX%" ^
    --with-openssl ^
    --with-libxml ^
    --with-xsl ^
    --with-curl ^
    --with-bz2 ^
    --with-gmp ^
    --with-sodium ^
    --enable-pdo ^
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
    --enable-sockets ^
    --with-zip
if errorlevel 1 exit /b 1

nmake /nologo
if errorlevel 1 exit /b 1

nmake /nologo install
if errorlevel 1 exit /b 1

rem PHP installs to Library/ root, but conda expects executables in Library/bin/
if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
move "%LIBRARY_PREFIX%\php.exe" "%LIBRARY_BIN%\php.exe"
move "%LIBRARY_PREFIX%\php-cgi.exe" "%LIBRARY_BIN%\php-cgi.exe"
move "%LIBRARY_PREFIX%\php8ts.dll" "%LIBRARY_BIN%\php8ts.dll"

rem Remove build tools that shouldn't be packaged
del /q "%LIBRARY_PREFIX%\gen_ir_fold_hash.exe" 2>nul
del /q "%LIBRARY_PREFIX%\minilua.exe" 2>nul
