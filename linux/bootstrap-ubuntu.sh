#!/usr/bin/env bash
#
#  - Bootstrap script for Ubuntu environment
#
# Usage:
#
#  ./bootstrap-ubuntu.sh
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


### Functions
##############################################################################

function __b3bp_log () {
    local log_level="${1}"
    shift

    # shellcheck disable=SC2034
    local color_info="\x1b[32m"
    local color_warning="\x1b[33m"
    # shellcheck disable=SC2034
    local color_error="\x1b[31m"

    local colorvar="color_${log_level}"

    local color="${!colorvar:-${color_error}}"
    local color_reset="\x1b[0m"

    if [[ "${NO_COLOR:-}" = "true" ]] || [[ "${TERM:-}" != "xterm"* ]] || [[ ! -t 2 ]]; then
        if [[ "${NO_COLOR:-}" != "false" ]]; then
        # Don't use colors on pipes or non-recognized terminals
        color=""; color_reset=""
        fi
    fi

    # all remaining arguments are to be printed
    local log_line=""

    while IFS=$'\n' read -r log_line; do
        echo -e "$(date -u +"%Y-%m-%d %H:%M:%S UTC") ${color}$(printf "[%9s]" "${log_level}")${color_reset} ${log_line}" 1>&2
    done <<< "${@:-}"
}

function error ()     { __b3bp_log error "${@}"; true; }
function warning ()   { __b3bp_log warning "${@}"; true; }
function info ()      { __b3bp_log info "${@}"; true; }


### Runtime
##############################################################################

# Initialization
info "Running 'sudo apt update'..."
sudo apt update > /dev/null 

# Install git
if ! [ -x "$(command -v git)" ]; then
    info "git not found. Installing git..."
    sudo apt install -y git
    info "Successfully installed git."
    info "Configuring git..."
    git config --global user.name "Ka Wo Fong"
    git config --global user.email "kawo123@hotmail.com"
    info "Successfully configured git."
fi

# Install Anaconda
if ! [ -x "$(command -v conda)" ]; then
    info "Downloading Anaconda installation script..."
    wget -P /tmp https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh
    info "Running Anaconda installation script..."
    bash /tmp/Anaconda3-2020.02-Linux-x86_64.sh
    info "Activating conda environment..."
    # TODO
fi

# Install Python virtualenv
if ! [ -x "$(command -v virtualenv)" ]; then
    info "Upgrading pip..."
    pip install --upgrade pip
    info "Installing Python virtualenv..."
    pip install virtualenv
    info "Successfully installed Python virtualenv."
fi

# Install Jupyter notebook
if ! [ -x "$(command -v jupyter)" ]; then
    info "Upgrading pip..."
    pip install --upgrade pip
    info "Installing Jupyter notebook..."
    pip install jupyter
    info "Successfully installed Jupyter notebook."
fi

# Install flake8
if ! [ -x "$(command -v flake8)" ]; then
    info "Upgrading pip..."
    pip install --upgrade pip
    info "Installing flake8..."
    pip install flake8
    info "Successfully installed flake8."
fi

# install autopep8
if ! [ -x "$(command -v autopep8)" ]; then
    info "Upgrading pip..."
    pip install --upgrade pip
    info "Installing autopep8..."
    pip install autopep8
    info "Successfully installed autopep8."
fi

# Install Node
if ! [ -x "$(command -v node)" ]; then
    info "Installing Node.js..."
    sudo apt install -y nodejs
    info "Successfully installed Node.js."
    info "Installing NPM..."
    sudo apt install -y npm
    info "Successfully installed NPM."
fi

# Install NPM
if ! [ -x "$(command -v npm)" ]; then
    info "Installing NPM..."
    sudo apt install -y npm
    info "Successfully installed NPM."
fi

# Install Azure CLI
if ! [ -x "$(command -v az)" ]; then
    info "Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    info "Successfully installed Azure CLI."
fi

# Install zsh
if ! [ -x "$(command -v zsh)" ]; then
    info "Installing zsh and oh-my-zsh..."
    sudo apt install -y zsh
    chsh -s $(which zsh)
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
    info "Successfully installed zsh and oh-my-zsh."
    info "Customizing oh-my-zsh..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k | zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions | zsh
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting | zsh
    info "Successfully customized oh-my-zsh..."
    zsh
fi


