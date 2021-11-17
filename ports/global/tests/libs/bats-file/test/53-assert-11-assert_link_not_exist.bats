#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

setup () {
  touch ${TEST_FIXTURE_ROOT}/dir/file
  ln -s ${TEST_FIXTURE_ROOT}/dir/file ${TEST_FIXTURE_ROOT}/dir/link

}
teardown () {
    rm -f ${TEST_FIXTURE_ROOT}/dir/link ${TEST_FIXTURE_ROOT}/dir/file
}


# Correctness
@test 'assert_link_not_exist() <file>: returns 0 if <file> is not a link' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/file"
  run assert_link_not_exist "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_link_not_exist() <file>: returns 1 and displays path if <file> symbolic link exists, but it was expected to be absent' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/link"
  run assert_link_not_exist "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  echo "${lines[0]}"  
  [ "${lines[0]}" == '-- symbolic link exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}

# Transforming path
@test 'assert_link_not_exist() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_link_not_exist "${TEST_FIXTURE_ROOT}/dir/link"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- symbolic link exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ../dir/link" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_link_not_exist() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%file'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_link_not_exist "${TEST_FIXTURE_ROOT}/dir/link"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- symbolic link exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/dir/link" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_link_not_exist() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_link_not_exist "${TEST_FIXTURE_ROOT}/dir/link"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- symbolic link exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/../link" ]
  [ "${lines[2]}" == '--' ]
}
