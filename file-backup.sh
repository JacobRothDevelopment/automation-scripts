#!/bin/bash

# example: sqlite-backup -f test.txt -t 7 -p backups

version="B 0.2.2"
debug_mode=0
dry_run_mode=0

# more here on colors:
# https://stackoverflow.com/q/5947742
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
cyan='\e[36m'
red='\e[31m'
yellow='\e[93m'
no_color='\e[0m'

version() { echo "script version $version"; }
newline() { echo ""; }
usage() { echo "USAGE: bash file-backup.sh -f <file path> -t <days> -p <backup path>"; }
separate() { echo "----------------------------------------------------------------"; }
debug() {
    if [ $debug_mode -gt 0 ]; then
        echo -e "${cyan}$1${no_color}"
    fi
}
error() { echo -e "${red}$1${no_color}"; }
warn() { echo -e "${yellow}$1${no_color}"; }
options() {
    cat <<-OPTIONS_LIST
  -d    debug mode
  -f    file path
  -h    help
  -p    path to backup directory
  -r    dry run mode (won't create or modify any files)
  -t    number of days to keep backups
  -v    version
OPTIONS_LIST
}
set_operation() {
    if [[ $operation == 0 || $operation == $1 ]]; then
        operation=$1
    else
        error "Only provide one operation at a time"
        debug "first operation: $operation"
        debug "second operation: $1"
        exit 1
    fi
}

operation=0

# check flags before doing any logic
# cspell:disable-next-line
while getopts ":f:t:p:drhvc" option; do
    case "${option}" in
        d) debug_mode=1 ;;
        f)
            file=${OPTARG}
            set_operation 'backup'
        ;;
        t)
            days=${OPTARG}
            set_operation 'backup'
        ;;
        p)
            path=${OPTARG}
            set_operation 'backup'
        ;;
        r) dry_run_mode=1 ;;
        c) set_operation 'cat' ;;
        v) set_operation 'version' ;;
        h) set_operation 'help' ;;
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

# run the chosen operation
case "${operation}" in
    'version')
        version
    ;;
    'help')
        version
        newline
        usage
        separate
        options
    ;;
    'cat')
        debug "you found the cat"
        echo -e " /\\_/\\ \n( o.o )\n > ^ <\n"
    ;;
    'backup')
        if [[ -z $file || -z $days || -z $path ]]; then
            debug "file: $file"
            debug "days: $days"
            debug "path: $path"
            usage
            exit 1
        fi
        
        mkdir -p $path
        
        baseFile=$(basename $file)
        extension="${baseFile#*.}"
        filename="${file%%.*}"
        date="$(date +%Y%m%d-%H%M%S)"
        
        if [ $dry_run_mode -eq 0 ]; then
            # delete old backups
            # find $path -mindepth 1 -mtime $days -delete
            find $path/$filename-*.$extension.gz -mtime $days -type f -delete
            debug "old files removed"
            
            # make new backup
            gzip -c $file >$path/$filename-$date.$extension.gz
            debug "backup created"
        else
            debug "filename: $filename"
            debug "extension: $extension"
            warn "No changes are made in dry run mode"
            echo "command to delete old backups:"
            echo "find $path/$filename-*.$extension.gz -mtime $days -type f -delete"
            
            echo -e "\nfiles to delete:"
            find $path/$filename-*.$extension.gz -mtime $days -type f
            
            echo -e "\nnew backup file:"
            echo "$path/$filename-$date.$extension.gz"
        fi
    ;;
    *)
        warn "no operation selected"
        debug "); you called me but didn't say anything"
        debug "now i feel useless"
    ;;
esac
