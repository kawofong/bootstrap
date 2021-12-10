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
# The MIT License (MIT)
# Copyright (c) 2013 Kevin van Zonneveld and contributors
# You are not obligated to bundle the LICENSE file with your b3bp projects as long
# as you leave these references intact in the header comments of your source files.
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
	curl
    dockutil
	git
	helm
	jq
	kubectl
	node
	python@3.9
	terraform
	tree
	watch
	wget
	xz
	zsh
)

HOMEBREW_CASKS=(
	docker
	# google-chrome
	google-cloud-sdk
	iterm2
    keepassx
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
	functions-framework
)

VSCODE_EXTENSIONS=(
    # General
    ms-vscode-remote.remote-ssh
    shan.code-settings-sync
    coenraads.bracket-pair-colorizer-2
    EditorConfig.EditorConfig
    HookyQR.beautify
    christian-kohler.path-intellisense
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
    # Shell
	foxundermoon.shell-format
	timonwong.shellcheck
    # Kubernetes
	ipedrazas.kubernetes-snippets
    # Terraform
    hashicorp.terraform
    # Theme
    nimda.deepdark-material
    pkief.material-icon-theme
)


### Function
##############################################################################

setup_macos() {
    # Change ownership of these directories to your user
    sudo chown -R $(whoami) /usr/local/bin \
        /usr/local/etc \
        /usr/local/sbin \
        /usr/local/share \
        /usr/local/share/doc

    # Add user write permission to these directories
    chmod u+w /usr/local/bin \
        /usr/local/etc \
        /usr/local/sbin \
        /usr/local/share \
        /usr/local/share/doc

    xcode-select --install || true # required for homebrew
    echo -n "Press any key to continue after xcode installation finishes (may take 20+ minutes)."
    read -s -r
}

install_homebrew() {
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
    if hash brew &>/dev/null; then
        info "Homebrew already installed. Getting updates..."
    else
        info "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

    # Clean up Dock applications
    dockutil --remove "Mail"
    dockutil --remove "Contacts"
    dockutil --remove "Calendar"
    dockutil --remove "Photos"
    dockutil --remove "Messages"
    dockutil --remove "Maps"
    dockutil --remove "FaceTime"
    dockutil --remove "Photo Booth"
    dockutil --remove "Music"
    dockutil --remove "Podcasts"
    dockutil --remove "TV"
    dockutil --remove "News"
    dockutil --remove "Books"
    dockutil --remove "Terminal"
    dockutil --add '' --type spacer --section apps --after "System Preferences"
    dockutil --add "/Applications/Google Chrome.app"
    dockutil --add "/Applications/Visual Studio Code.app"
    dockutil --add "/Applications/Sublime Text.app"
    dockutil --add "/Applications/iTerm.app"
    dockutil --add "/Applications/KeePassX.app"
    killall Dock

    info "macOS configuration completes."
}


### Runtime
##############################################################################

setup_macos
install_homebrew
install_homebrew_formulae
install_python_modules
install_homebrew_casks
install_vscode_extensions
# configure_macos

info "You will have to re-login for new macOS configurations to take effect"
info "You will have to manually configure some settings like night shift"
