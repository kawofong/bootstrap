#!/usr/bin/env bash
#
#  - Bootstrap script for Debian/Ubuntu based environment, including WSL
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

##############################################################################
### Import
##############################################################################

source ./logging.sh

##############################################################################
### Variable
##############################################################################

BOOTSTRAP_COMPONENT="ALL"

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

DEFAULT_PYTHON_VERSION="3.11.8"

PYTHON_PACKAGES=(
    poetry
)

VSCODE_EXTENSIONS=(
    # General
    christian-kohler.path-intellisense
    EditorConfig.EditorConfig
    esbenp.prettier-vscode
    github.copilot
    github.copilot-chat
    ms-vscode-remote.remote-containers
    ms-vscode-remote.remote-ssh
    ms-vsliveshare.vsliveshare
    Rubymaniac.vscode-direnv
    # Git
    codezombiech.gitignore
    eamodio.gitlens
    waderyan.gitblame
    # Markdown
    yzhang.markdown-all-in-one
    # Python
    ms-python.python
    ms-python.pylint
    ms-python.flake8
    ms-python.black-formatter
    # Shell
    foxundermoon.shell-format
    # Theme
    nimda.deepdark-material
    pkief.material-icon-theme
)

##############################################################################
### Function
##############################################################################

# Function to install apt packages
# Parameters:
#   - packages: an array of package names to be installed
install_apt_packages() {
    local -r packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        warning "No apt packages provided. Skipping apt package installation."
        return
    fi
    info "Updating apt repo..."
    sudo apt update
    info "Installing apt packages..."
    sudo apt install -y "${packages[@]}"
    info "Apt packages installation completes."
}

# Function: install_oh_my_zsh
# Description:
#   - Function to install oh-my-zsh if it is not already installed.
#     If the $ZSH folder already exists, the installation is skipped.
#     Otherwise, oh-my-zsh is installed using the official installation script.
#     After installation, the default shell is changed to zsh.
#     If the shell change fails, it returns true and proceeds.
# Parameters: None
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

# Function: install_zsh_extensions
# Description:
#   - Install oh-my-zsh extensions if they are not already installed.
#     If the oh-my-zsh extensions are already installed,
#     the installation is skipped.
# Parameters: None
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

# Function: install_pyenv
# Description:
#   - Installs pyenv if it is not already installed.
#     Sets up the necessary environment variables and installs a specific version of Python using pyenv.
# Parameters: None
install_pyenv() {
    info "Installing pyenv."
    if ! command -v pyenv &>/dev/null; then
        curl -L "https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer" | bash
        export PATH="${PYENV_ROOT}/bin:${PATH}"
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
        info "pyenv installation completes."
    else
        info "pyenv is already installed. Skipping pyenv installation."
    fi
}

# Function: install_python
# Description: Installs Python using pyenv if Python is not already installed.
# Parameters:
#   - python_version: Optional. The version of Python to install. If not provided, it uses the DEFAULT_PYTHON_VERSION.
install_python() {
    local -r python_version="${1:?"args[1] omitted; expected Python version."}"
    info "Installing python @ ${python_version}."
    if ! command -v pyenv &>/dev/null; then
        info "pyenv is not installed. Installing pyenv."
        install_pyenv
    fi
    # Check if Python version matches python_version
    if ! command -v python &>/dev/null || [[ "$(python --version 2>&1)" != "${python_version}" ]]; then
        pyenv install "${python_version}"
        pyenv global "${python_version}"
        info "python @ ${python_version} installation completes."
    else
        info "python is already installed and matches the desired version. Skipping python installation."
    fi
}

# Function: install_python_modules
# Description: Installs Python modules using pip3.
# Parameters:
#   - modules: An array of Python module names to install.
install_python_modules() {
    local -r modules=("$@")
    if [ ${#modules[@]} -eq 0 ]; then
        warning "No Python modules provided. Skipping module installation."
        return
    fi
    info "Installing Python modules..."
    pip3 install "${modules[@]}"
    info "Python modules installation completes."
}

# Function to install VS Code extensions
# Parameters:
#   - extensions: an array of extension names
install_vscode_extensions() {
    local -r extensions=("$@")
    if ! command -v code &>/dev/null; then
        warning "VS Code is not installed in this environment. Skipping extension installation."
    else
        info "Installing VS Code extensions..."
        for i in "${extensions[@]}"; do
            code --install-extension "$i"
        done
        info "VS Code extensions installation completes."
    fi
}

###################################################################
# Parse arguments
###################################################################

# set +u
set +o nounset
while :; do
    case $1 in
    --cli-only)
        log "Flag '--cli-only' is used. Only bootstrap CLI tools."
        BOOTSTRAP_COMPONENT="CLI"
        shift
        ;;
    '') # end of options
        break
        ;;
    *) # unknown argument - this prevents infinite loop in the installer and provides feedback
        die "'$1' is unknown argument."
        ;;
    esac
done
# set -u
set -o nounset

##############################################################################
### Runtime
##############################################################################

install_apt_packages "${PACKAGES[@]}"
install_oh_my_zsh
install_zsh_extensions
install_pyenv
install_python "${DEFAULT_PYTHON_VERSION}"
install_python_modules "${PYTHON_PACKAGES[@]}"
if [[ "${BOOTSTRAP_COMPONENT}" == "ALL" ]]; then
    install_vscode_extensions "${VSCODE_EXTENSIONS[@]}"
fi
