#!/usr/bin/env bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/bats-file/load'
load helpers/log
load helpers/os
load helpers/device

source ../global-functions

setup_file() {
  init_log
}
setup() {
  export ROOT_DIR="$(temp_make)"
}

@test "get os - 351ELEC" {
  create_351elec
  run get_os
  assert_output "351ELEC"
}

@test "get os - ArkOS" {
  create_arkos
  run get_os
  assert_output "ArkOS"
}
@test "get os - TheRA" {
  create_the_ra
  run get_os
  assert_output "TheRA"
}
@test "get os - ubuntu" {
  create_ubuntu
  run get_os
  assert_output "ubuntu"
}
@test "get os - unknown" {
  run get_os
  assert_output "unknown"
}
@test "get device - RG351P" {
  create_rg351p
  run get_device
  assert_output "rg351p"
}
@test "get device - RG351V" {
  create_rg351v
  run get_device
  assert_output "rg351v"
}
@test "get device - RG351MP" {
  create_rg351mp
  run get_device
  assert_output "rg351mp"
}

@test "get device - OdroidGoAdvance" {
  create_oga
  run get_device
  assert_output "oga"
}

@test "get device - OdroidGoSuper" {
  create_ogs
  run get_device
  assert_output "ogs"
}

@test "get device - rk2020" {
  create_rk2020
  run get_device
  assert_output "rk2020"
}

@test "get device - Gameforce Chi" {
  create_chi
  run get_device
  assert_output "chi"
}

@test "get device - Gameforce Chi" {
  create_chi
  run get_device
  assert_output "chi"
}