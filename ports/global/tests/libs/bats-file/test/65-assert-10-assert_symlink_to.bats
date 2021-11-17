#!/usr/bin/env bats
load 'test_helper'
fixtures 'symlink'

setup () {
 touch ${TEST_FIXTURE_ROOT}/file ${TEST_FIXTURE_ROOT}/notasymlink
 ln -s ${TEST_FIXTURE_ROOT}/file ${TEST_FIXTURE_ROOT}/symlink
 
}
teardown () {
    rm -f ${TEST_FIXTURE_ROOT}/file ${TEST_FIXTURE_ROOT}/notasymlink ${TEST_FIXTURE_ROOT}/symlink
}

# Correctness
@test 'assert_symlink_to() <file> <link>: returns 0 if <link> exists and is a symbolic link to <file>' {
  local -r file="${TEST_FIXTURE_ROOT}/file"
  local -r link="${TEST_FIXTURE_ROOT}/symlink"
  run assert_symlink_to $file $link
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}
@test 'assert_symlink_to() <file> <link>: returns 1 and displays path if <link> is not a symbolic link to <file>' {
  local -r file="${TEST_FIXTURE_ROOT}/dir/file.does_not_exist"
  local -r link="${TEST_FIXTURE_ROOT}/symlink"
  run assert_symlink_to $file $link
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- symbolic link does not have the correct target --' ]
  [ "${lines[1]}" == "path : $link" ]
  [ "${lines[2]}" == '--' ]
}
