#!/usr/bin/env bats

load 'test_helper'
fixtures 'temp'


# Correctness
@test 'temp_make() <var>: returns 0, creates a temporary directory and displays its path' {
  teardown() { rm -r -- "$TEST_TEMP_DIR"; }

  TEST_TEMP_DIR="$(temp_make)"

  local -r literal="${BATS_TMPDIR}/${BATS_TEST_FILENAME##*/}-"
  local -r pattern='[1-9][0-9]*-.{10}'
  [[ $TEST_TEMP_DIR =~ ^"${literal}"${pattern}$ ]] || false
  [ -e "$TEST_TEMP_DIR" ]
}

@test 'temp_make() <var>: returns 1 and displays an error message if the directory can not be created' {
  local -r BATS_TMPDIR='/does/not/exist'
  run temp_make

  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: temp_make --' ]
  [[ ${lines[1]} == 'mktemp: failed to create directory via template'* ]]
  [ "${lines[2]}" == '--' ]
}

@test "temp_make() <var>: works when called from \`setup'" {
  bats "${TEST_FIXTURE_ROOT}/temp_make-setup.bats"
}

@test "temp_make() <var>: works when called from \`@test'" {
  bats "${TEST_FIXTURE_ROOT}/temp_make-test.bats"
}

@test "temp_make() <var>: works when called from \`teardown'" {
  bats "${TEST_FIXTURE_ROOT}/temp_make-teardown.bats"
}

@test "temp_make() <var>: does not work when called from \`main'" {
  run bats "${TEST_FIXTURE_ROOT}/temp_make-main.bats"

  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: temp_make --' ]
  [ "${lines[1]}" == "Must be called from \`setup', \`@test' or \`teardown'" ]
  [ "${lines[2]}" == '--' ]
}

# Options
test_p_prefix() {
  teardown() { rm -r -- "$TEST_TEMP_DIR"; }

  TEST_TEMP_DIR="$(temp_make "$@" 'test-')"

  local -r literal="${BATS_TMPDIR}/test-${BATS_TEST_FILENAME##*/}-"
  local -r pattern='[1-9][0-9]*-.{10}'
  [[ $TEST_TEMP_DIR =~ ^"${literal}"${pattern}$ ]] || false
  [ -e "$TEST_TEMP_DIR" ]
}

@test 'temp_make() -p <prefix> <var>: returns 0 and creates a temporary directory with <prefix> prefix' {
  test_p_prefix -p
}

@test 'temp_make() --prefix <prefix> <var>: returns 0 and creates a temporary directory with <prefix> prefix' {
  test_p_prefix --prefix
}

@test "temp_make() --prefix <prefix> <var>: works if <prefix> starts with a \`-'" {
  teardown() { rm -r -- "$TEST_TEMP_DIR"; }

  TEST_TEMP_DIR="$(temp_make --prefix -)"

  [ -e "$TEST_TEMP_DIR" ]
}
