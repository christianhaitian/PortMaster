
BATS_LOG_FILE=./bats.log
output() {
  echo "$(date): $1" >> ${BATS_LOG_FILE}
}
init_log() {
  echo "" > ${BATS_LOG_FILE}
}