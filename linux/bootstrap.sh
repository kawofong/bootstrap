#!/usr/bin/env bash
#
#  - Bootstrap script for Linux machines
#
# Usage:
#
#  ./bootstrap.sh
#
# Based on a template by BASH3 Boilerplate v2.3.0
# http://bash3boilerplate.sh/#authors
#
# The MIT License (MIT)
# Copyright (c) 2013 Kevin van Zonneveld and contributors
# You are not obligated to bundle the LICENSE file with your b3bp projects as long
# as you leave these references intact in the header comments of your source files.

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace


### Import
##############################################################################

source ./logging.sh


### Function
##############################################################################

backup_file() {
    mv "${HOME}/$1" "${HOME}/$1.bak"
    ln -s "${HOME}/bootstrap/$1" "${HOME}/$1"
}

setup_dotfiles() {
    backup_file .alias
    backup_file .bashrc
    backup_file .gitconfig
    backup_file .p10k.zsh
    backup_file .zshrc
}


### Runtime
##############################################################################

setup_dotfiles

# Debian/Ubuntu based systems
if [ -f "/etc/debian_version" ]; then
    info "Debian/Ubuntu based systems found."
fi

# Redhat/CentOS based systems
if [ -f "/etc/redhat-release" ]; then
    info "Redhat/CentOS based systems found."
    error "Redhat/CentOS based systems are not supported yet."
    exit 1
fi

# MacOS
if [ -f "/usr/bin/sw_vers" ]; then
    info "MacOS found."
    error "MacOS is not supported yet."
    exit 1
fi
