#!/bin/sh
set -o errexit
set -o xtrace

git clone --depth 1 https://github.com/bats-core/bats-core
cd bats-core && ./install.sh "${HOME}/.local" && cd .. && rm -rf bats-core
