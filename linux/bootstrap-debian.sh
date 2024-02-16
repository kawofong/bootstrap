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
    # Start general
    apt-transport-https
    ca-certificates
    curl
    git-all
    gnupg
    jq
    lsb-release
    wget
    zsh
    # End general
    # Start pyenv
    build-essential
    libbz2-dev
    libffi-dev
    liblzma-dev
    libncurses5-dev
    libncursesw5-dev
    libreadline-dev
    libsqlite3-dev
    libssl-dev
    llvm
    make
    python3-dev
    tk-dev
    xz-utils
    zlib1g-dev
    # End pyenv
)

PYTHON_PACKAGES=(
    poetry
)

### Function
##############################################################################

install_apt_packages() {
    info "Updating apt repo..."
    sudo apt update
    info "Installing apt packages..."
    sudo apt install -y "${PACKAGES[@]}"
    info "Apt packages installation completes."
}

install_oh_my_zsh() {
    if [ -d "${HOME}/.oh-my-zsh" ]; then
        info "The \$ZSH folder already exists (${HOME}/.oh-my-zsh)."
        info "Skipping oh-my-zsh installation."
    else
        info "Installing oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    chsh -s $(which zsh) || true # always return true and proceed
}

install_zsh_extensions() {
    info "Installing zsh extensions..."
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k | zsh
    fi
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions | zsh
    fi
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting | zsh
    fi
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/print-alias" ]; then
        git clone https://github.com/brymck/print-alias ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/print-alias | zsh
    fi

    info "Zsh extensions installation completes."
}

install_docker() {
    # Reference: https://docs.docker.com/engine/install/debian/
    sudo apt-get remove docker docker.io containerd runc | true # ignore if don't exist
    info "Removed old versions of docker."
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    info "Added Docker’s official GPG key."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    info "Set up the docker stable repository."
    sudo apt update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    info "Docker installation completes."
}

install_google_cloud_sdk() {
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    info "Added Google Cloud SDK distribution URI as a package source."
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    info "Imported the Google Cloud public key."
    sudo apt-get update && sudo apt-get install google-cloud-sdk
    info "Google Cloud SDK installation completes."
}

install_pyenv() {
    PYTHON_VERSION="3.12.2"
    info "Installing pyenv."
    if ! command -v pyenv &> /dev/null; then
        curl -L "https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer" | bash
        export PATH="${PYENV_ROOT}/bin:${PATH}"
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
        pyenv install "${PYTHON_VERSION}"
        info "pyenv installation completes."
    else
        info "pyenv is already installed. Skipping pyenv installation."
    fi
}

install_python() {
    PYTHON_VERSION="3.12.2"
    info "Installing python @ ${PYTHON_VERSION}."
    if ! command -v python &> /dev/null; then
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
        pyenv install "${PYTHON_VERSION}"
        pyenv global "${PYTHON_VERSION}"
        info "python @ ${PYTHON_VERSION} installation completes."
    else
        info "python is already installed. Skipping python installation."
    fi
}

install_python_modules() {
    info "Installing Python modules..."
    pip3 install "${PYTHON_PACKAGES[@]}"
    info "Python modules installation completes."
}

install_terraform() {
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    info "Added the HashiCorp GPG key."
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    info "Added the official HashiCorp Linux repository."
    sudo apt-get update && sudo apt-get install terraform
    info "Terraform installation completes."
}

### Runtime
##############################################################################

install_apt_packages
install_oh_my_zsh
install_zsh_extensions
install_pyenv
install_python
install_python_modules
# install_docker
# install_google_cloud_sdk
# install_terraform

