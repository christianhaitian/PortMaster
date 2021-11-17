#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

setup () {
  touch ${TEST_FIXTURE_ROOT}/dir/execfile ${TEST_FIXTURE_ROOT}/dir/noexecfile
  chmod +x ${TEST_FIXTURE_ROOT}/dir/execfile

}
teardown () {
    rm -f ${TEST_FIXTURE_ROOT}/dir/execfile ${TEST_FIXTURE_ROOT}/dir/noexecfile
}

# Correctness
@test 'assert_file_not_executable() <file>: returns 0 if <file> is not executable' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/noexecfile"
  run assert_file_not_executable "$file"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_file_not_executable() <file>: returns 1 and displays path if <file> is executable' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/execfile"
  run assert_file_not_executable "$file"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file is executable, but it was expected to be not executable --' ]
  [ "${lines[1]}" == "path : $file" ]
  [ "${lines[2]}" == '--' ]
}

# Transforming path
@test 'assert_file_not_executable() <file>: replace prefix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_not_executable "${TEST_FIXTURE_ROOT}/dir/execfile"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file is executable, but it was expected to be not executable --' ]
  [ "${lines[1]}" == "path : ../dir/execfile" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_file_not_executable() <file>: replace suffix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='%file'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_not_executable "${TEST_FIXTURE_ROOT}/dir"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file is executable, but it was expected to be not executable --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/dir" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_file_not_executable() <file>: replace infix of displayed path' {
  local -r BATSLIB_FILE_PATH_REM='dir'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_file_not_executable "${TEST_FIXTURE_ROOT}/dir/execfile"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- file is executable, but it was expected to be not executable --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/../execfile" ]
  [ "${lines[2]}" == '--' ]
}
