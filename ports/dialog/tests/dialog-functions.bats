#!/usr/bin/env bats
load '../../global/tests/libs/bats-support/load'
load '../../global/tests/libs/bats-assert/load'
load '../../global/tests/libs/bats-file/load'
load ../../global/tests/helpers/log
load ../../global/tests/helpers/os
load ../../global/tests/helpers/device
source ../../global/global-functions

source ../dialog-functions

setup_file() {
  init_log
}
setup() {
  export __ROOT_DIR="$(temp_make)"
}

@test "dialog init - 351ELEC" {
  create_351elec
  run dialog_initialize
}
