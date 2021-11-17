#!/usr/bin/env bats
load 'test_helper'
fixtures 'empty'
# Correctness
@test 'assert_file_size_equals() <file>: returns 0 if <file> <size> correct' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/empty-file"
  run assert_file_size_equals "$file" "0"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}
@test 'assert_file_size_equals() <file>: returns 1 if <file> <size> is not correct' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/non-empty-file"
  run assert_file_size_equals "$file" "5"
  [ "$status" -eq 1 ]
}
@test 'assert_file_size_equals() <file>: returns 0 if <file> <size> is correct, non-zero case' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/non-empty-file"
  run assert_file_size_equals "$file" "10"
  [ "$status" -eq 0 ]
}
# Transforming path
@test 'assert_file_size_equals() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_size_equals "${TEST_FIXTURE_ROOT}/dir/non-empty-file" "5"
  [ "$status" -eq 1 ]
}
@test 'assert_file_size_equals() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%non-empty-file'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_size_equals "${TEST_FIXTURE_ROOT}/dir/non-empty-file" "5"
  [ "$status" -eq 1 ]
}
@test 'assert_file_size_equals() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_size_equals "${TEST_FIXTURE_ROOT}/dir/non-empty-file" "5"
  [ "$status" -eq 1 ]
}
