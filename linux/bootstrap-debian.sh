#!/usr/bin/env bash
#
#  - Bootstrap script for Debian/Ubuntu based machines
#
# Usage:
#
#  ./bootstrap-debian.sh
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


### Variable
##############################################################################

PACKAGES=(
    git-all
    jq
)


### Function
##############################################################################

install_apt_packages() {
    info "Updating apt repo..."
    sudo apt update
    info "Installing apt packages..."
    sudo apt install -y "${PACKAGES[@]}"
    info "Installation of apt packages complete."
}

generate_git_ssh_key() {
    # generate ssh key
    ssh-keygen -t rsa -C "14829553+kawo123@users.noreply.github.com"
    info '##### Please see below for SSH public key: '
    cat ~/.ssh/id_rsa.pub
    info '##### Follow step 4 to complete: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account'
    info '##### After you added SSH key to your GitHub account, you can run "ssh -T git@github.com" to verify your configuration.'
}

### Runtime
##############################################################################

install_apt_packages
generate_git_ssh_key
