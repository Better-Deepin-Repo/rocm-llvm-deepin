#!/bin/sh
# Pin all packages from the experimental suite at high priority so that
# autopkgtest's testbed can pull in deps (rocminfo, libhsa-runtime, ...) that
# currently only live in experimental. Run via autopkgtest --setup-commands.

set -e

cat >/etc/apt/preferences.d/99experimental <<EOT
Package: *
Pin: release a=experimental
Pin-Priority: 900
EOT

apt-get update
