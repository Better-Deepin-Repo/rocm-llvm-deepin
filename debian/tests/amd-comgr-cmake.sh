#! /bin/sh
set -e

if [ "${AUTOPKGTEST_TMP}" = "" ]
then
	AUTOPKGTEST_TMP=$(mktemp -d /tmp/amd-comgr-cmake-test.XXXXXX)
	# shellcheck disable=SC2064
	trap "rm -rf ${AUTOPKGTEST_TMP}" 0 INT QUIT ABRT PIPE TERM
fi
cd "$AUTOPKGTEST_TMP"

cat > CMakeLists.txt << 'END'
cmake_minimum_required(VERSION 3.13)
project(amd_comgr_consumer C)
find_package(amd_comgr REQUIRED)
message(STATUS "amd_comgr_DIR=${amd_comgr_DIR}")
message(STATUS "amd_comgr_VERSION=${amd_comgr_VERSION}")
add_executable(probe probe.c)
target_link_libraries(probe PRIVATE amd_comgr)
END

cat > probe.c << 'END'
#include <stdio.h>
#include <amd_comgr/amd_comgr.h>

int main(void) {
	size_t major = 0, minor = 0;
	amd_comgr_get_version(&major, &minor);
	printf("amd_comgr runtime version: %zu.%zu\n", major, minor);
	return 0;
}
END

echo '$ cmake -S . -B build'
cmake -S . -B build
echo '$ cmake --build build'
cmake --build build
echo '$ ./build/probe'
./build/probe
