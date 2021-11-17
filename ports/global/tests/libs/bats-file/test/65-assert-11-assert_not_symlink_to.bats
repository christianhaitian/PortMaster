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
@test 'assert_not_symlink_to() <file> <link>: returns 0 if <link> exists and is a not symbolic link to <file>' {
  local -r file="${TEST_FIXTURE_ROOT}/file"
  local -r link="${TEST_FIXTURE_ROOT}/notasymlink"
  run assert_not_symlink_to $file $link
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}
@test 'assert_not_symlink_to() <file> <link>: returns 1 and displays path if <link> is a symbolic link to <file>' {
  local -r file="${TEST_FIXTURE_ROOT}/file"
  local -r link="${TEST_FIXTURE_ROOT}/symlink"
  run assert_not_symlink_to $file $link
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 6 ]
  [ "${lines[0]}" == '-- file is a symbolic link --' ]
  [ "${lines[1]}" == "path : $link" ]
  [ "${lines[2]}" == '--' ]
  [ "${lines[3]}" == '-- symbolic link does have the correct target --' ]
  [ "${lines[4]}" == "path : $link" ]
  [ "${lines[5]}" == '--' ]
}
