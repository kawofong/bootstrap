#!/usr/bin/env bash
#
#  - Bootstrap script for macOS machines
#
# Usage:
#
#  ./bootstrap-macos.sh
#
# Based on a template by BASH3 Boilerplate v2.3.0
# http://bash3boilerplate.sh/#authors
#
# This is idempotent so it can be run multiple times.
#
# Credits:
#
# - https://sourabhbajaj.com/mac-setup/
# - https://gist.github.com/mrichman/f5c0c6f0c0873392c719265dfd209e12
# - https://developer.apple.com/documentation/devicemanagement/profile-specific_payload_keys
#
# Additional resources:
# - https://github.com/romkatv/powerlevel10k
# - https://github.com/romkatv/powerlevel10k/issues/671
# - https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins

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

HOMEBREW_FORMULAE=(
    bash
    bash-completion
    cask
    commitizen
    curl
    dockutil
    git
    helm
    jq
    kubectl
    poetry
    pyenv
    ruby
    shellcheck
    terraform
    tree
    watch
    wget
    xz
    zsh
)

HOMEBREW_CASKS=(
    docker
    google-chrome
    google-cloud-sdk
    iterm2
    keepassx
    mactex
    microsoft-remote-desktop
    postman
    rectangle
    sublime-text
    visual-studio-code
    zappy
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
    christian-kohler.path-intellisense
    EditorConfig.EditorConfig
    ms-vscode-remote.remote-containers
    ms-vscode-remote.remote-ssh
    ms-vsliveshare.vsliveshare
    shan.code-settings-sync
    HookyQR.beautify
    tomoki1207.pdf
    visualstudioexptteam.vscodeintellicode
    wayou.vscode-todo-highlight
    # Git
    codezombiech.gitignore
    donjayamanne.githistory
    eamodio.gitlens
    waderyan.gitblame
    # Markdown
    yzhang.markdown-all-in-one
    # Web / node
    Zignd.html-css-class-completion
    christian-kohler.npm-intellisense
    dbaeumer.jshint
    eg2.vscode-npm-script
    mohsen1.prettify-json
    kamikillerto.vscode-colorize
    # Python
    ms-python.python
    ms-python.vscode-pylance
    # Shell
    foxundermoon.shell-format
    timonwong.shellcheck
    # Kubernetes
    ipedrazas.kubernetes-snippets
    ms-azuretools.vscode-docker
    # Terraform
    hashicorp.terraform
    # Theme
    nimda.deepdark-material
    pkief.material-icon-theme
)

### Function
##############################################################################

setup_macos() {
    # TODO: these directories do not exist in fresh install
    # Change ownership of these directories to your user
    # sudo chown -R $(whoami) /usr/local/bin \
    #     /usr/local/etc \
    #     /usr/local/sbin \
    #     /usr/local/share \
    #     /usr/local/share/doc

    # Add user write permission to these directories
    # chmod u+w /usr/local/bin \
    #     /usr/local/etc \
    #     /usr/local/sbin \
    #     /usr/local/share \
    #     /usr/local/share/doc

    xcode-select --install || true # required for homebrew
    echo -n "Press any key to continue after xcode installation finishes (may take 20+ minutes)."
    read -s -r
    echo ""
}

install_homebrew() {
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
    if hash brew &>/dev/null; then
        info "Homebrew already installed. Getting updates..."
    else
        info "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        info "Adding /opt/homebrew/bin to PATH."
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
        info "Homebrew installation completes." 
    fi

    # Update homebrew recipes
    brew update
    brew upgrade
}

install_homebrew_formulae() {
    info "Installing Homebrew formulae..."
    brew install "${HOMEBREW_FORMULAE[@]}"
    info "Homebrew formulae installation completes."
}

install_homebrew_casks() {
    info "Installing Homebrew casks..."
    brew install --cask "${HOMEBREW_CASKS[@]}"
    info "Homebrew casks installation completes."
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

install_python() {
    PYTHON_VERSION=3.10
    info "Installing Python ${PYTHON_VERSION} using pyenv..."
    pyenv install ${PYTHON_VERSION} && pyenv global ${PYTHON_VERSION}
    eval "$(pyenv init -)"
    info "Python installation completes."
}

install_python_modules() {
    info "Installing Python modules..."
    pip install --user "${PYTHON_PACKAGES[@]}"
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

configure_macos() {
    info "Configuring macOS..."
    # Set fast key repeat rate
    # The step values that correspond to the sliders on the GUI are as follow (lower equals faster):
    # KeyRepeat: 120, 90, 60, 30, 12, 6, 2
    # InitialKeyRepeat: 120, 94, 68, 35, 25, 15
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 35

    # Set Dark theme
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

    # Always show scrollbars
    defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

    # Set trackpad speed
    defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5

    # Show filename extensions by default
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Expanded Save menu
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Expanded Print menu
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Require password as soon as screensaver or sleep mode starts
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    # Add Traditional Chinese in languages
    defaults write -g AppleLanguages -array en-US zh-Hant-US

    # Enable tap-to-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Hide recent apps from Dock
    defaults write com.apple.dock show-recents -bool false

    # TODO: dockutil does not work on new MacOS (https://github.com/kcrawford/dockutil/issues/127)
    # Clean up Dock applications
    # dockutil --remove "Mail"
    # dockutil --remove "Contacts"
    # dockutil --remove "Calendar"
    # dockutil --remove "Photos"
    # dockutil --remove "Messages"
    # dockutil --remove "Maps"
    # dockutil --remove "FaceTime"
    # dockutil --remove "Photo Booth"
    # dockutil --remove "Music"
    # dockutil --remove "Podcasts"
    # dockutil --remove "TV"
    # dockutil --remove "News"
    # dockutil --remove "Books"
    # dockutil --remove "Terminal"
    # dockutil --add '' --type spacer --section apps --after "System Preferences"
    # dockutil --add "/Applications/Google Chrome.app"
    # dockutil --add "/Applications/Visual Studio Code.app"
    # dockutil --add "/Applications/Sublime Text.app"
    # dockutil --add "/Applications/iTerm.app"
    # dockutil --add "/Applications/KeePassX.app"
    # killall Dock

    info "macOS configuration completes."
}

### Runtime
##############################################################################

setup_macos
install_homebrew
install_homebrew_formulae
install_oh_my_zsh
install_zsh_extensions
install_python
install_python_modules
install_homebrew_casks
install_vscode_extensions
configure_macos

info "You will have to re-login for new macOS configurations to take effect"
info "You will have to manually configure some settings like night shift"
