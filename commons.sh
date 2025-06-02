#!/bin/bash

# region consts
version="B 0.0.0"

debug_mode=0
dry_run_mode=0

cyan='\e[36m'
red='\e[31m'
green='\e[2;32m'
green_bg='\e[1;42m'
yellow='\e[93m'
no_color='\e[0m'

# endregion

# region functions
version() { echo "$version"; }
usage() { echo "TODO USAGE"; } # TODO usage
separate() { echo "----------------------------------------------------------------"; }
debug() {
    if [ $debug_mode -gt 0 ]; then
        echo -e "${cyan}$*${no_color}"
    fi
}
error() { echo -e "${red}$*${no_color}"; }
activity() { echo -e "${green}$*${no_color}"; }
success() { echo -e "${green_bg}$*${no_color}"; }
warn() { echo -e "${yellow}$*${no_color}"; }
options() {  # TODO options
    cat <<-OPTIONS_LIST
  -d    debug mode
  -h    help
  -v    version
OPTIONS_LIST
}
# endregion

# cspell:disable-next-line
while getopts "drhv" option; do
    case "${option}" in
        d) debug_mode=1 ;;
        r) dry_run_mode=1 ;;
        v)
            version
            exit 1
        ;;
        h)
            version
            usage
            separate
            options
        ;;
        :)
            echo "Option -${OPTARG} requires an argument."
            exit 1
        ;;
        \?)
            echo "Invalid option: -${OPTARG}."
            exit 1
        ;;
    esac
done
