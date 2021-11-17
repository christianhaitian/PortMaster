#!/usr/bin/env bats

load 'test_helper'

@test "temp_make() <var>: works when called from \`@test'" {
  TEST_TEMP_DIR="$(temp_make)"
}

teardown() {
  rm -r -- "$TEST_TEMP_DIR"
}
