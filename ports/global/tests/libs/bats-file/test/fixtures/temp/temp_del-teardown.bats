#!/usr/bin/env bats

load 'test_helper'

@test "temp_del() <path>: \`BATSLIB_TEMP_PRESERVE_ON_FAILURE' works when called from \`teardown'" {
  false
}

teardown() {
  local -ir BATSLIB_TEMP_PRESERVE_ON_FAILURE=1
  temp_del "$TEST_TEMP_DIR"
}
