#!/usr/bin/env bats

load 'test_helper'
fixtures 'temp'


# Correctness
@test 'temp_del() <path>: returns 0 and deletes <path>' {
  TEST_TEMP_DIR="$(temp_make)"
  run temp_del "$TEST_TEMP_DIR"

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
  [ ! -e "$TEST_TEMP_DIR" ]
}

@test 'temp_del() <path>: returns 1 and displays an error message if <path> can not be deleted' {
  local -r path="${TEST_FIXTURE_ROOT}/does/not/exist"
  run temp_del "$path"

  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: temp_del --' ]
  # Travis CI's Ubuntu 12.04, quotes the path with a backtick and an
  # apostrophe, instead of just apostrophes.
  [[ ${lines[1]} =~ 'rm: cannot remove '.${path}.': No such file or directory' ]]
  [ "${lines[2]}" == '--' ]
}

@test "temp_del() <path>: works if <path> starts with a \`-'" {
  TEST_TEMP_DIR="$(temp_make --prefix -)"
  run temp_del "$TEST_TEMP_DIR"

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
  [ ! -e "$TEST_TEMP_DIR" ]
}

# Environment variables
@test "temp_del() <path>: returns 0 and does not delete <path> if \`BATSLIB_TEMP_PRESERVE' is set to \`1'" {
  teardown() { rm -r -- "$TEST_TEMP_DIR"; }

  TEST_TEMP_DIR="$(temp_make)"
  local -r BATSLIB_TEMP_PRESERVE=1
  run temp_del "$TEST_TEMP_DIR"

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
  [ -e "$TEST_TEMP_DIR" ]
}

@test "temp_del() <path>: returns 0 and does not delete <path> if \`BATSLIB_TEMP_PRESERVE_ON_FAILURE' is set to \`1' and the test have failed" {
  teardown() { rm -r -- "$TEST_TEMP_DIR"; }

  TEST_TEMP_DIR="$(temp_make)"
  export TEST_TEMP_DIR
  run bats "${TEST_FIXTURE_ROOT}/temp_del-fail.bats"

  [ "$status" -eq 1 ]
  [ -e "$TEST_TEMP_DIR" ]
}

@test "temp_del() <path>: returns 0 and deletes <path> if \`BATSLIB_TEMP_PRESERVE_ON_FAILURE' is set to \`1' and the test have passed" {
  TEST_TEMP_DIR="$(temp_make)"
  export TEST_TEMP_DIR
  run bats "${TEST_FIXTURE_ROOT}/temp_del-pass.bats"

  [ "$status" -eq 0 ]
  [ ! -e "$TEST_TEMP_DIR" ]
}

@test "temp_del() <path>: returns 0 and deletes <path> if \`BATSLIB_TEMP_PRESERVE_ON_FAILURE' is set to \`1' and the test have been skipped" {
  TEST_TEMP_DIR="$(temp_make)"
  export TEST_TEMP_DIR
  run bats "${TEST_FIXTURE_ROOT}/temp_del-skip.bats"

  [ "$status" -eq 0 ]
  [ ! -e "$TEST_TEMP_DIR" ]
}

@test "temp_del() <path>: \`BATSLIB_TEMP_PRESERVE_ON_FAILURE' works when called from \`teardown'" {
  teardown() { rm -r -- "$TEST_TEMP_DIR"; }

  TEST_TEMP_DIR="$(temp_make)"
  export TEST_TEMP_DIR
  run bats "${TEST_FIXTURE_ROOT}/temp_del-teardown.bats"

  [ "$status" -eq 1 ]
  [ -e "$TEST_TEMP_DIR" ]
}

@test "temp_del() <path>: \`BATSLIB_TEMP_PRESERVE_ON_FAILURE' does not work when called from \`main'" {
  teardown() { rm -r -- "$TEST_TEMP_DIR"; }

  TEST_TEMP_DIR="$(temp_make)"
  export TEST_TEMP_DIR
  run bats "${TEST_FIXTURE_ROOT}/temp_del-main.bats"

  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: temp_del --' ]
  [ "${lines[1]}" == "Must be called from \`teardown' when using \`BATSLIB_TEMP_PRESERVE_ON_FAILURE'" ]
  [ "${lines[2]}" == '--' ]
}

@test "temp_del() <path>: \`BATSLIB_TEMP_PRESERVE_ON_FAILURE' does not work when called from \`setup'" {
  teardown() { rm -r -- "$TEST_TEMP_DIR"; }

  TEST_TEMP_DIR="$(temp_make)"
  export TEST_TEMP_DIR
  run bats "${TEST_FIXTURE_ROOT}/temp_del-setup.bats"

  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 10 ]
  [[ ${lines[6]} == *'-- ERROR: temp_del --' ]] || false
  [[ ${lines[7]} == *"Must be called from \`teardown' when using \`BATSLIB_TEMP_PRESERVE_ON_FAILURE'" ]] || false
  [[ ${lines[8]} == *'--' ]] || false
}

@test "temp_del() <path>: \`BATSLIB_TEMP_PRESERVE_ON_FAILURE' does not work when called from \`@test'" {
  teardown() { rm -r -- "$TEST_TEMP_DIR"; }

  TEST_TEMP_DIR="$(temp_make)"
  export TEST_TEMP_DIR
  run bats "${TEST_FIXTURE_ROOT}/temp_del-test.bats"

  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 10 ]
  [[ ${lines[6]} == *'-- ERROR: temp_del --' ]] || false
  [[ ${lines[7]} == *"Must be called from \`teardown' when using \`BATSLIB_TEMP_PRESERVE_ON_FAILURE'" ]] || false
  [[ ${lines[8]} == *'--' ]] || false
}
