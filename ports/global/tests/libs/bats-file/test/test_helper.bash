# Set variables for easily accessing sub-directories of `./fixtures'.
#
# Globals:
#   BATS_TEST_DIRNAME
#   TEST_FIXTURE_ROOT
#   TEST_RELATIVE_FIXTURE_ROOT
# Arguments:
#   $1 - name of sub-directory
# Returns:
#   none
fixtures() {
  TEST_FIXTURE_ROOT="${BATS_TEST_DIRNAME}/fixtures/$1"
  TEST_RELATIVE_FIXTURE_ROOT=$(bats_trim_filename "${TEST_FIXTURE_ROOT}" TEST_RELATIVE_FIXTURE_ROOT)
}

export TEST_MAIN_DIR="${BATS_TEST_DIRNAME}/.."
export TEST_DEPS_DIR="${TEST_DEPS_DIR-${TEST_MAIN_DIR}/..}"

# Load dependencies.
load "${TEST_DEPS_DIR}/bats-support/load.bash"
# Load library.
load '../load'
