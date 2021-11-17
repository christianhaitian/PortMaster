#!/usr/bin/env bats

load 'test_helper'

@test "temp_del() <path>: returns 0 and deletes <path> if \`BATSLIB_TEMP_PRESERVE_ON_FAILURE' is set to \`1' and the test have been skipped" {
  skip
}

teardown() {
  local -ir BATSLIB_TEMP_PRESERVE_ON_FAILURE=1
  temp_del "$TEST_TEMP_DIR"
}
