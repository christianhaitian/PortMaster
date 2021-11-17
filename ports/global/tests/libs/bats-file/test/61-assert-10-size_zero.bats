#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

setup () {
  touch ${TEST_FIXTURE_ROOT}/dir/zerobyte  
} 

teardown () {  
  rm -f ${TEST_FIXTURE_ROOT}/dir/zerobyte ${TEST_FIXTURE_ROOT}/dir/notzerobyte
}


# Correctness
@test 'assert_size_zero() <file>: returns 0 if <file> file is 0 byte' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/zerobyte"
  run assert_size_zero "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_size_zero() <file>: returns 1 and displays path if <file> file is greater than 0 byte' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/notzerobyte"
  run assert_size_zero "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file is greater than 0 byte --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}



# Transforming path
@test 'assert_size_zero() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_size_zero "${TEST_FIXTURE_ROOT}/dir/notzerobyte"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file is greater than 0 byte --' ]
  [ "${lines[1]}" == "path : ../dir/notzerobyte" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_size_zero() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%dir/notzerobyte'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_size_zero "${TEST_FIXTURE_ROOT}/dir/notzerobyte"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file is greater than 0 byte --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/.." ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_size_zero() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir/notzerobyte'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_size_zero "${TEST_FIXTURE_ROOT}/dir/notzerobyte"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file is greater than 0 byte --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/.." ]
  [ "${lines[2]}" == '--' ]
}
