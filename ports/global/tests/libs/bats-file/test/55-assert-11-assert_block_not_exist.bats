#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

setup () {
 sudo mknod ${TEST_FIXTURE_ROOT}/dir/blockfile b 89 1
}
teardown () {
    rm -f ${TEST_FIXTURE_ROOT}/dir/blockfile
}

# Correctness
@test 'assert_block_not_exist() <file>: returns 0 if <file> block special does not exist' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/file"
  run assert_block_not_exist "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_block_not_exist() <file>: returns 1 and displays path if <file> block special file exists, but it was expected to be absent' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/blockfile"
  run assert_block_not_exist "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- block special file exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}

# Transforming path
@test 'assert_block_not_exist() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_block_not_exist "${TEST_FIXTURE_ROOT}/dir/blockfile"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- block special file exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ../dir/blockfile" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_block_not_exist() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%blockfile'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_block_not_exist "${TEST_FIXTURE_ROOT}/dir/blockfile"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- block special file exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/dir/.." ]
  [ "${lines[2]}" == '--' ]

}

@test 'assert_block_not_exist() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_block_not_exist "${TEST_FIXTURE_ROOT}/dir/blockfile"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- block special file exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/../blockfile" ]
  [ "${lines[2]}" == '--' ]
}

