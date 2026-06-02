#! /bin/sh
set -e

# hipconfig must be a standalone tool that prints config values for each
# query flag. CMake's FindHIP.cmake and CMakeDetermineHIPCompiler.cmake
# rely on these outputs to discover the toolchain. A regression that turned
# hipconfig into a passthrough wrapper would let `--check` pass while still
# breaking every CMake-driven HIP build, so query each consumer-facing flag
# explicitly and assert the output looks right.

assert_nonempty() {
	flag="$1"
	value="$2"
	if [ -z "${value}" ]; then
		echo "hipconfig ${flag}: expected non-empty output" >&2
		exit 1
	fi
}

assert_equals() {
	flag="$1"
	expected="$2"
	actual="$3"
	if [ "${actual}" != "${expected}" ]; then
		echo "hipconfig ${flag}: expected '${expected}', got '${actual}'" >&2
		exit 1
	fi
}

echo '$ hipconfig --check'
hipconfig --check

echo '$ hipconfig --platform'
platform=$(hipconfig --platform)
echo "${platform}"
assert_equals --platform amd "${platform}"

echo '$ hipconfig --compiler'
compiler=$(hipconfig --compiler)
echo "${compiler}"
assert_equals --compiler clang "${compiler}"

echo '$ hipconfig --runtime'
runtime=$(hipconfig --runtime)
echo "${runtime}"
assert_equals --runtime rocclr "${runtime}"

echo '$ hipconfig --path'
hip_path=$(hipconfig --path)
echo "${hip_path}"
assert_nonempty --path "${hip_path}"

echo '$ hipconfig --rocmpath'
rocm_path=$(hipconfig --rocmpath)
echo "${rocm_path}"
assert_nonempty --rocmpath "${rocm_path}"

echo '$ hipconfig --hipclangpath'
clang_path=$(hipconfig --hipclangpath)
echo "${clang_path}"
assert_nonempty --hipclangpath "${clang_path}"
if [ ! -x "${clang_path}/clang++" ]; then
	echo "hipconfig --hipclangpath: '${clang_path}/clang++' is not executable" >&2
	exit 1
fi

echo '$ hipconfig --version'
version=$(hipconfig --version)
echo "${version}"
assert_nonempty --version "${version}"
