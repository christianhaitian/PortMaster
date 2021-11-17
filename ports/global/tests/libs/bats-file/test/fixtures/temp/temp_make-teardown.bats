#!/usr/bin/env bats

load 'test_helper'

@test "temp_make() <var>: works when called from \`teardown'" {
  true
}

teardown() {
  TEST_TEMP_DIR="$(temp_make)"
  rm -r -- "$TEST_TEMP_DIR"
}
