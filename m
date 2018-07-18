#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME="$(basename "$0")"

VSCODE="code"
if [[ "${SCRIPT_DIR}" == *"Code - Insiders"* ]]; then
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

sub_uninstall_extra() {
  comm -13 <(sort "${SCRIPT_DIR}/extensions") <("${VSCODE}" --list-extensions | sort) | xargs -I % ${VSCODE} --uninstall-extension %
  printf "Finished uninstalling extensions\n"
}

sub_sync() {
  sub_install
  sub_uninstall_extra
}

sub_help() {
  printf "
Usage:
  ./%s <subcommand> [options]

Subcommands:
  save      Write all current extensions to extensions file
  install   Read extensions file, and install all extensions from it
  sync      Installs all extensions in extensions file, then writes all current extensions back to that file
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
