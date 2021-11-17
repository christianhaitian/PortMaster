#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

setup () {
  mkfifo ${TEST_FIXTURE_ROOT}/dir/testpipe
}
teardown () {
    rm -f ${TEST_FIXTURE_ROOT}/dir/testpipe
}


# Correctness
@test 'assert_fifo_not_exist() <file>: returns 0 if <file> fifo does not exists' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/file"
  run assert_fifo_not_exist "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_fifo_not_exist() <file>: returns 1 and displays path if <file> fifo exists, but it was expected to be absent' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/testpipe"
  run assert_fifo_not_exist "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- fifo exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}

# Transforming path
@test 'assert_fifo_not_exist() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_fifo_not_exist "${TEST_FIXTURE_ROOT}/dir/testpipe"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- fifo exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ../dir/testpipe" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_fifo_not_exist() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%testpipe'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_fifo_not_exist "${TEST_FIXTURE_ROOT}/dir/testpipe"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- fifo exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/dir/.." ]
  [ "${lines[2]}" == '--' ]

}

@test 'assert_fifo_not_exist() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_fifo_not_exist "${TEST_FIXTURE_ROOT}/dir/testpipe"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- fifo exists, but it was expected to be absent --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/../testpipe" ]
  [ "${lines[2]}" == '--' ]
}

