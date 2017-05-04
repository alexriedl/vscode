#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME="$(basename $0)"
VSCODE="code"

sub_save() {
  ${VSCODE} --list-extensions > extensions
  if [ $? -eq 0 ]; then
    printf "Saved extension list\n"
  else
    printf "Failed to save extension list\n"
  fi
}

sub_install() {
  <extensions xargs -I % ${VSCODE} --install-extension %
  printf "Finished installing extensions\n"
}

sub_sync() {
  sub_install
  sub_save
}

sub_help() {
  printf "
Usage:
  ./${SCRIPT_NAME} <subcommand> [options]

Subcommands:
  save      Write all current extensions to extensions file
  install   Read extensions file, and install all extensions from it
  sync      Installs all extensions in extensions file, then writes all current extensions back to that file
\n\n"
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
      sub_${subcommand}_help
    else
      sub_$subcommand $@
    fi

    # Report unknown subcommands
    if [ $? = 127 ]; then
      printf "Error: '$subcommand' is not a known subcommand.\n" >&2
      printf "  Run './$ProgName --help' for a list of known subcommands.\n" >&2
      exit 1
    fi
    ;;
esac
