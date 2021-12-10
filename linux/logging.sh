#!/usr/bin/env bash
#
#  - Bash library providing logging functions
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
