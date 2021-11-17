#!/usr/bin/env bats
load 'test_helper'
fixtures 'empty'
# Correctness
@test 'assert_file_not_empty() <file>: returns 0 if <file> is not empty' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/non-empty-file"
  run assert_file_not_empty "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}
@test 'assert_file_not_empty() <file>: returns 1 and displays path if <file> emptys' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/empty-file"
  run assert_file_not_empty "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file empty, but it was expected to contain something --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}
# Transforming path
@test 'assert_file_not_empty() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_not_empty "${TEST_FIXTURE_ROOT}/dir/empty-file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file empty, but it was expected to contain something --' ]
  [ "${lines[1]}" == "path : ../dir/empty-file" ]
  [ "${lines[2]}" == '--' ]
}
@test 'assert_file_not_empty() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%empty-file'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_not_empty "${TEST_FIXTURE_ROOT}/dir/empty-file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file empty, but it was expected to contain something --' ]
echo  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/dir/.." ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/dir/.." ]
  [ "${lines[2]}" == '--' ]
}
@test 'assert_file_not_empty() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_not_empty "${TEST_FIXTURE_ROOT}/dir/empty-file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file empty, but it was expected to contain something --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/../empty-file" ]
  [ "${lines[2]}" == '--' ]
}
