#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME="$(basename "$0")"

VSCODE="code"
if [[ "${SCRIPT_DIR}" == *"VSCodium"* ]]; then
  VSCODE="vscodium"
elif [[ "${SCRIPT_DIR}" == *"Code - Insiders"* ]]; then
  VSCODE="code-insiders"
fi

printf "Using '%s' as vscode binary\n" "${VSCODE}"

sub_save() {
  if ${VSCODE} --list-extensions | sort > "${SCRIPT_DIR}/extensions"; then
    printf "Saved extension list\n"
  else
    printf "Failed to save extension list\n"
  fi
}

sub_install() {
  comm -13 <("${VSCODE}" --list-extensions | sort) <(sort "${SCRIPT_DIR}/extensions") | xargs -I % ${VSCODE} --install-extension %
  printf "Finished installing extensions\n"
}

sub_rm_extra() {
  comm -13 <(sort "${SCRIPT_DIR}/extensions") <("${VSCODE}" --list-extensions | sort) | xargs -I % ${VSCODE} --uninstall-extension %
  printf "Finished uninstalling extra extensions\n"
}

sub_sync() {
  sub_install
  sub_rm_extra
}

sub_help() {
  printf "
Usage:
  ./%s <subcommand> [options]

Subcommands:
  save     Write all currently installed extensions to the extensions file
  install  Ensures all extensions in the extensions file are installed
  rm_extra Uninstalls all extensions that are not in the extensions file
  sync     Ensures all extensions in the extensions file are installed and uninstalls all extensions that are not in that file
\n\n" "${SCRIPT_NAME}"
}

subcommand=$1
case $subcommand in
  "" | "-h" | "--help")
    sub_help
    ;;
  *)
    # Drop the argument that is the name of the subcommand
    shift

    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
      "sub_${subcommand}_help"
    else
      "sub_$subcommand" "$@"
    fi

    # Report unknown subcommands
    if [ $? = 127 ]; then
      printf "Error: '%s' is not a known subcommand.\n" "${subcommand}" >&2
      printf "  Run './%s --help' for a list of known subcommands.\n" "${SCRIPT_NAME}" >&2
      exit 1
    fi
    ;;
esac
