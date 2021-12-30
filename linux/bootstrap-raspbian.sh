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
    code
    curl
    git-all
    jq
    nodejs
    npm
    # Python 3
    python3
    python3-pip
    build-essential
    libssl-dev
    libffi-dev
    python3-dev
    python3-rpi.gpio
    # end Python 3
    zsh
)

PYTHON_PACKAGES=(
    autopep8
    flake8
    ipython
    virtualenv
    virtualenvwrapper
)

VSCODE_EXTENSIONS=(
    # General
    shan.code-settings-sync
    EditorConfig.EditorConfig
    HookyQR.beautify
    christian-kohler.path-intellisense
    visualstudioexptteam.vscodeintellicode
    wayou.vscode-todo-highlight
    # Git
    codezombiech.gitignore
    donjayamanne.githistory
    eamodio.gitlens
    # Markdown
    yzhang.markdown-all-in-one
    # Web / node
    christian-kohler.npm-intellisense
    dbaeumer.jshint
    eg2.vscode-npm-script
    mohsen1.prettify-json
    kamikillerto.vscode-colorize
    # Python
    ms-python.python
    # Shell
    foxundermoon.shell-format
    timonwong.shellcheck
    # Theme
    nimda.deepdark-material
    pkief.material-icon-theme
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

install_python_modules() {
    info "Installing Python modules..."
    pip3 install --user "${PYTHON_PACKAGES[@]}"
    info "Python modules installation completes."
}

install_vscode_extensions() {
    if hash code &>/dev/null; then
        info "Installing VS Code extensions..."
        for i in "${VSCODE_EXTENSIONS[@]}"; do
            code --install-extension "$i"
        done
        info "VS Code extensions installation completes."
    fi
}

### Runtime
##############################################################################

install_apt_packages
install_oh_my_zsh
install_zsh_extensions
install_docker
install_python_modules
install_vscode_extensions
