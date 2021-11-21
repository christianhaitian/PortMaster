
create_ubuntu() {
  output "creating ubuntu stub file system in: ${ROOR_DIR}"
  mkdir "${__ROOT_DIR}/etc"
  echo "ID=ubuntu" > "${__ROOT_DIR}/etc/os-release"
}

create_351elec() {
  output "creating 351ELEC stub file system in: ${ROOR_DIR}"
  mkdir -p "${__ROOT_DIR}/storage/.config"
  echo "351ELEC" > "${__ROOT_DIR}/storage/.config/.OS_ARCH"
}

create_arkos() {
  output "creating ArkOS stub file system in: ${ROOR_DIR}"
  mkdir -p "${__ROOT_DIR}/opt/system/Advanced/"
}

create_the_ra() {
  output "creating TheRA stub file system in: ${ROOR_DIR}"
  mkdir -p ${__ROOT_DIR}/usr/share/plymouth/themes
  
  echo "title=\"TheRA\"" > "${__ROOT_DIR}/usr/share/plymouth/themes/text.plymouth"
}

