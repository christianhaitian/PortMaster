#!/usr/bin/env bats

load 'test_helper'

setup() {
  local -ir BATSLIB_TEMP_PRESERVE_ON_FAILURE=1
  temp_del "$TEST_TEMP_DIR"
}

@test "temp_del() <path>: \`BATSLIB_TEMP_PRESERVE_ON_FAILURE' does not work when called from \`setup'" {
  true
}
