# Qt Paths
QT_VERSION=6.8.1
QT_ROOT=~/Qt/$QT_VERSION
QT_PLATFORM=$QT_ROOT/macos
QT_BIN=$QT_PLATFORM/bin
QT_SRC=$QT_ROOT/Src
QT_SQLDRIVERS=$QT_SRC/qtbase/src/plugins/sqldrivers

# MySQL Paths
MySQL_ROOT=/usr/local/mysql
MySQL_INCLUDE=$MySQL_ROOT/include
MySQL_LIBRARY=$MySQL_ROOT/lib/libmysqlclient.dylib

BUILD_PATH=~/Documents/build-sqldriver
# If you want to install to PySide/PyQt, you can change this to
# ~/anaconda3/envs/$env_name/lib/python$version/site-packages/PySide6/Qt
INSTALL_PATH=$QT_PLATFORM

mkdir $BUILD_PATH
cd $BUILD_PATH
# Bug 0: They said this bug will be fixed in 6.8.2. Use -no-sbom workaround for now.
$QT_BIN/qt-configure-module $QT_SQLDRIVERS -no-sbom -sql-mysql -- -DMySQL_ROOT=$MySQL_ROOT
# Bug 1: CMAKE_OSX_ARCHITECTURES=arm64 doesn't work, so we have to change it manually.
#        The flag is added in case it's supported in the future.
arch=$(arch)
if [[ $arch =~ ^arm ]]; then
  ARCH_FLAG=-DCMAKE_OSX_ARCHITECTURES=arm64
fi
$QT_BIN/qt-cmake -G Ninja $QT_SQLDRIVERS -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DMySQL_INCLUDE_DIR=$MySQL_INCLUDE -DMySQL_LIBRARY=$MySQL_LIBRARY $ARCH_FLAG
if [[ $arch =~ ^arm ]]; then
  sed -i -e 's/-arch x86_64/-arch arm64/g' ./build.ninja
fi
cmake --build .
# Bug 2: Link path for MySQL library is relative, which is incorrect.
# find the real filename of mysql
MYSQL_LIB_FILENAME=$(basename $(realpath $MySQL_LIBRARY))
install_name_tool -change @rpath/$MYSQL_LIB_FILENAME $MySQL_ROOT/lib/$MYSQL_LIB_FILENAME $BUILD_PATH/plugins/sqldrivers/libqsqlmysql.dylib
cmake --install .
