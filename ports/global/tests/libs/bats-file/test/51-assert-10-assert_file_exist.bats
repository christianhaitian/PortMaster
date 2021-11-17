#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

setup () {
  touch ${TEST_FIXTURE_ROOT}/dir/file
}
teardown () {
    rm -f ${TEST_FIXTURE_ROOT}/dir/file
}

# Correctness
@test 'assert_file_exist() <file>: returns 0 if <file> exists' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/file"
  run assert_file_exist "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_file_exist() <file>: returns 1 and displays path if <file> does not exist' {
  local -r file="${TEST_FIXTURE_ROOT}/dir"
  run assert_file_exist "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file does not exist --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}

# Transforming path
@test 'assert_file_exist() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_exist "${TEST_FIXTURE_ROOT}/dir"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file does not exist --' ]
  [ "${lines[1]}" == "path : ../dir" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_file_exist() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%file.does_not_exist'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_exist "${TEST_FIXTURE_ROOT}/dir"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file does not exist --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/dir" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_file_exist() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_exist "${TEST_FIXTURE_ROOT}/dir"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file does not exist --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/.." ]
  [ "${lines[2]}" == '--' ]
}
