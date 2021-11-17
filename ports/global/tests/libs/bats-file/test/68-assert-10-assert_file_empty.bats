#!/usr/bin/env bats
load 'test_helper'
fixtures 'empty'
# Correctness
@test 'assert_file_empty() <file>: returns 0 if <file> empty' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/empty-file"
  run assert_file_empty "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}
@test 'assert_file_empty() <file>: returns 1 and displays content if <file> is not empty' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/non-empty-file"
  run assert_file_empty "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- file is not empty --' ]
  [ "${lines[1]}" == "path     : ${TEST_FIXTURE_ROOT}/dir/non-empty-file" ]
  [ "${lines[2]}" == 'output   : Not empty' ]
  [ "${lines[3]}" == '--' ]
}
# Transforming path
@test 'assert_file_empty() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_empty "${TEST_FIXTURE_ROOT}/dir/non-empty-file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- file is not empty --' ]
  [ "${lines[1]}" == "path     : ../dir/non-empty-file" ]
  [ "${lines[2]}" == 'output   : Not empty' ]
  [ "${lines[3]}" == '--' ]
}
@test 'assert_file_empty() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%non-empty-file'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_empty "${TEST_FIXTURE_ROOT}/dir/non-empty-file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- file is not empty --' ]
  [ "${lines[1]}" == "path     : ${TEST_FIXTURE_ROOT}/dir/.." ]
  [ "${lines[2]}" == 'output   : Not empty' ]
  [ "${lines[3]}" == '--' ]
}
@test 'assert_file_empty() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_empty "${TEST_FIXTURE_ROOT}/dir/non-empty-file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- file is not empty --' ]
  [ "${lines[1]}" == "path     : ${TEST_FIXTURE_ROOT}/../non-empty-file" ]
  [ "${lines[2]}" == 'output   : Not empty' ]
  [ "${lines[3]}" == '--' ]
}
