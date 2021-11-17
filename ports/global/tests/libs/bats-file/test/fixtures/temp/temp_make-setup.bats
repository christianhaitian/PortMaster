#!/usr/bin/env bats

load 'test_helper'

setup() {
  TEST_TEMP_DIR="$(temp_make)"
}

@test "temp_make() <var>: works when called from \`setup'" {
  true
}

teardown() {
  rm -r -- "$TEST_TEMP_DIR"
}
