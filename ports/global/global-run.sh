#! /bin/bash
set -e
DIR="$(realpath $( dirname "${BASH_SOURCE[0]}" ))"

# This should be replaced on install
PACKAGE=__PACKAGE__

pushd "${DIR}/${PACKAGE}" &> /dev/null
bash -x ./run