#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

setup () {
 touch ${TEST_FIXTURE_ROOT}/dir/owner ${TEST_FIXTURE_ROOT}/dir/notowner
}
teardown () {
    rm -f ${TEST_FIXTURE_ROOT}/dir/owner ${TEST_FIXTURE_ROOT}/dir/notowner
}


# Correctness
@test 'assert_file_owner() <file>: returns 0 if <file> user root is the owner of the file' {
  local -r owner="root"
  local -r file="${TEST_FIXTURE_ROOT}/dir/owner"
  run assert_file_owner "$owner" "$file"
  [ "$status" -eq 0 ]
  echo ${#lines[@]}
  [ "${#lines[@]}" -eq 0 ] 

}

@test 'assert_file_owner() <file>: returns 1 and displays path if <file> user root is not the owner of the file' {
  local -r owner="root"
  local -r file="${TEST_FIXTURE_ROOT}/dir/notowner"
  run assert_file_owner "$owner" "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- user root is not the owner of the file --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}



# Transforming path
@test 'assert_file_owner() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  local -r owner="root"
  local -r file="${TEST_FIXTURE_ROOT}/dir/notowner"
  run assert_file_owner "$owner" "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- user root is not the owner of the file --' ]
  [ "${lines[1]}" == "path : ../dir/notowner" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_file_owner() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%dir/notowner'
  local -r BATSLIB_FILE_PATH_ADD='..'
  local -r owner="root"
  local -r file="${TEST_FIXTURE_ROOT}/dir/notowner"
  run assert_file_owner "$owner" "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- user root is not the owner of the file --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/.." ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_file_owner() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir/notowner'
  local -r BATSLIB_FILE_PATH_ADD='..'
  local -r owner="root"
  local -r file="${TEST_FIXTURE_ROOT}/dir/notowner"
  run assert_file_owner "$owner" "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- user root is not the owner of the file --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/.." ]
  [ "${lines[2]}" == '--' ]
}
