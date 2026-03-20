@echo off
setlocal enabledelayedexpansion

cd /d "%SRC_DIR%"

rem Patch out the PHP SDK binary tools version check - we don't use the PHP SDK
sed -i "s/if (BIN_TOOLS_SDK_VER_MAJOR < 2)/if (false)/" win32\build\confutils.js

rem Fix libxml2 for shared library from conda-forge:
rem - Add libxml2.lib to search list
rem - Remove LIBXML_STATIC flags (we link dynamically)
rem - Remove DEF file that re-exports 1500+ libxml2 symbols
sed -i "s/libxml2_a_dll.lib;libxml2_a.lib/libxml2_a_dll.lib;libxml2_a.lib;libxml2.lib/" ext\libxml\config.w32
sed -i "s/LIBXML_STATIC \/D LIBXML_STATIC_FOR_DLL \/D //" ext\libxml\config.w32
sed -i "/ADD_DEF_FILE.*php_libxml2.def/d" ext\libxml\config.w32

rem Guard xmlDllMain call - only needed for static libxml2
sed -i "s/ifdef HAVE_LIBXML/ifdef LIBXML_STATIC_FOR_DLL/" win32\dllmain.c

rem Fix xsl: add shared lib names and remove LIBXML_STATIC flag
sed -i "s/libxslt_a.lib/libxslt_a.lib;xslt.lib;libxslt.lib/" ext\xsl\config.w32
sed -i "s/libexslt_a.lib/libexslt_a.lib;exslt.lib;libexslt.lib/" ext\xsl\config.w32
sed -i "s/\/D LIBXML_STATIC\"/\"/" ext\xsl\config.w32

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
