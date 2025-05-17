# Qt Paths
QT_VERSION=6.9.0
QT_ROOT=~/Qt/$QT_VERSION
QT_PLATFORM=$QT_ROOT/macos
QT_BIN=$QT_PLATFORM/bin
QT_SRC=$QT_ROOT/Src
QT_SQLDRIVERS=$QT_SRC/qtbase/src/plugins/sqldrivers

# MySQL Paths
MySQL_ROOT=/usr/local/mysql
MySQL_INCLUDE=$MySQL_ROOT/include
MySQL_LIBRARY=$MySQL_ROOT/lib/libmysqlclient.dylib

BUILD_PATH=./build-sqldriver
# If you want to install to PySide/PyQt, you can change this to
# ~/anaconda3/envs/$env_name/lib/python$version/site-packages/PySide6/Qt
INSTALL_PATH=$QT_PLATFORM

mkdir $BUILD_PATH
cd $BUILD_PATH
$QT_BIN/qt-cmake -G Ninja $QT_SQLDRIVERS -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DMySQL_INCLUDE_DIR=$MySQL_INCLUDE -DMySQL_LIBRARY=$MySQL_LIBRARY -DCMAKE_OSX_ARCHITECTURES=$(arch) -DQT_FORCE_MACOS_ALL_ARCHES=ON
cmake --build .
cmake --install .
# Bug 2: MySQL library is in @rpath after build, but not in install
install_name_tool -add_rpath $MySQL_ROOT/lib $QT_PLATFORM/plugins/sqldrivers/libqsqlmysql.dylib