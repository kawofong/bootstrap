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
    if [ -f "${HOME}/$1" ] || [ -h "${HOME}/$1" ]; then
        mv "${HOME}/$1" "${HOME}/$1.bak"
        info "${HOME}/$1 backed up."
    fi
    ln -s "${HOME}/bootstrap/linux/$1" "${HOME}/$1"
    info "Setup for $1 complete."
}

setup_dotfiles() {
    backup_file .alias
    backup_file .bashrc
    backup_file .gitconfig
    backup_file .p10k.zsh
    backup_file .zshrc
}

generate_git_ssh_key() {
    if [[ ! -f ~/.ssh/id_rsa ]]; then
        info "Generating SSH key..."
        ssh-keygen -t rsa -C "14829553+kawo123@users.noreply.github.com"
        info "##### Please see below for SSH public key: "
        cat ~/.ssh/id_rsa.pub
        info "##### Follow step 4 to complete: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"
        info '##### After you added SSH key to your GitHub account, you can run "ssh -T git@github.com" to verify your configuration.'
    fi
}

bootstrap_workspace() {
    info "Bootstrapping workspace..."
    [[ ! -d "${HOME}/Workspace" ]] && mkdir "${HOME}/Workspace"
    info "Workspace boostrap completes."
}

### Runtime
##############################################################################

info "Bootstrap starting. You may be asked for your password (for sudo)."
setup_dotfiles
generate_git_ssh_key
bootstrap_workspace

# Debian/Ubuntu based systems
if [ -f "/etc/debian_version" ]; then
    info "Debian/Ubuntu based systems found. Bootstrapping system..."
    source ./bootstrap-debian.sh
fi

# Redhat/CentOS based systems
if [ -f "/etc/redhat-release" ]; then
    info "Redhat/CentOS based systems found."
    error "Redhat/CentOS based systems are not supported yet."
    exit 1
fi

# MacOS
if [ -f "/usr/bin/sw_vers" ]; then
    info "macOS found. Bootstrapping system..."
    source ./bootstrap-macos.sh
fi

info "System bootstrap complete."
