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
    apt-transport-https
    ca-certificates
    software-properties-common
    curl
    git-all
    gnupg
    jq
    kubectl
    lsb-release
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

install_docker() {
    # Reference: https://docs.docker.com/engine/install/debian/
    sudo apt-get remove docker docker.io containerd runc | true # ignore if don't exist
    info "Removed old versions of docker."
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    info "Added Docker’s official GPG key."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    info "Set up the docker stable repository."
    sudo apt update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
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

install_terraform() {
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    info "Added the HashiCorp GPG key."
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    info "Added the official HashiCorp Linux repository."
    sudo apt-get update && sudo apt-get install terraform
    info "Terraform installation completes."
}

generate_git_ssh_key() {
    if [[ ! -f ~/.ssh/id_rsa ]]; then
        ssh-keygen -t rsa -C "14829553+kawo123@users.noreply.github.com"
        info "##### Please see below for SSH public key: "
        cat ~/.ssh/id_rsa.pub
        info "##### Follow step 4 to complete: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"
        info '##### After you added SSH key to your GitHub account, you can run "ssh -T git@github.com" to verify your configuration.'
    fi
}

### Runtime
##############################################################################

install_apt_packages
# install_docker
install_google_cloud_sdk
# install_terraform
generate_git_ssh_key
