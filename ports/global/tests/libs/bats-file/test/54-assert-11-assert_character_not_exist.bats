#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

setup () {
 sudo mknod ${TEST_FIXTURE_ROOT}/dir/test_device c 89 1
}
teardown () {
    rm -f ${TEST_FIXTURE_ROOT}/dir/test_device
}

# Correctness
@test 'assert_character_not_exist() <file>: returns 0 if <file> character special file does not exist' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/file"
  run assert_character_not_exist "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_character_not_exist() <file>: returns 1 and displays path if <file> character special file exists, but it was expected to be absent' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/test_device"
  run assert_character_not_exist "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- character special file exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}

# Transforming path
@test 'assert_character_not_exist() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_character_not_exist "${TEST_FIXTURE_ROOT}/dir/test_device"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- character special file exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ../dir/test_device" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_character_not_exist() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%file'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_character_not_exist "${TEST_FIXTURE_ROOT}/dir/test_device"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- character special file exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/dir/test_device" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_character_not_exist() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_character_not_exist "${TEST_FIXTURE_ROOT}/dir/test_device"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- character special file exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/../test_device" ]
  [ "${lines[2]}" == '--' ]
}
