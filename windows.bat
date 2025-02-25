@echo off

setlocal

set BuildDir=%cd%\build-sqldriver

set QtRoot=C:\Qt
set QtVersion=%QtRoot%\6.8.2
set QtSrc=%QtVersion%\Src
set QtSqlDrivers=%QtSrc%\qtbase\src\plugins\sqldrivers
set QtPlatform=%QtVersion%\mingw_64
set QtBin=%QtPlatform%\bin
set QtTools=%QtRoot%\Tools

set MySQLRoot=C:\Program Files\MySQL\MySQL Server 9.2
set MySQLInclude=%MySQLRoot%\include
set MySQLLibrary=%MySQLRoot%\lib\libmysql.lib

set MySQLIncludeTemp=%BuildDir%\include
set MySQLLibraryTemp=%BuildDir%\lib\libmysql.lib

mkdir %BuildDir%
cd /d %BuildDir%
echo d | xcopy /s "%MySQLInclude%" %MySQLIncludeTemp%
mkdir lib
copy "%MySQLLibrary%" %MySQLLibraryTemp%
call %QtBin%\qt-cmake.bat -G Ninja %QtSqlDrivers% -DCMAKE_INSTALL_PREFIX="%QtPlatform%" -DMySQL_INCLUDE_DIR="%MySQLIncludeTemp%" -DMySQL_LIBRARY="%MySQLLibraryTemp%"
cmake --build .
cmake --install .

echo Please add these to path:
echo %MySQLRoot%\lib
echo %MySQLRoot%\bin
echo %QtBin%

endlocal