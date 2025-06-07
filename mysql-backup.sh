#!/bin/bash

# example: mysql-backup -n test -t 7 -p backups

version="1.0.3"
debug_mode=0

# more here on colors:
# https://stackoverflow.com/q/5947742
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
cyan='\e[36m'
red='\e[31m'
yellow='\e[93m'
no_color='\e[0m'

version() { echo "script version $version"; }
newline() { echo ""; }
usage() { echo "USAGE: bash mysql-backup.sh -n <database name> -t <days> -p <path>"; }
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
  -h    help
  -n    database name
  -p    path to backup directory
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
while getopts ":n:t:p:dhvc" option; do
    case "${option}" in
        d) debug_mode=1 ;;
        n)
            database=${OPTARG}
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
        c) set_operation 'cat' ;;
        v) set_operation 'version' ;;
        h) set_operation 'help' ;;
        :)
            error "Option -${OPTARG} requires an argument."
            exit 1
        ;;
        \?)
            error "Invalid option: -${OPTARG}."
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
        if [[ -z $database || -z $days || -z $path ]]; then
            debug "database: $database"
            debug "days: $days"
            debug "path: $path"
            usage
            exit 1
        fi
        
        mkdir -p $path
        
        # delete old backups
        # find $path -mindepth 1 -mtime $days -delete
        find $path/$database-*.sql.gz -mtime $days -type f -delete
        
        # make new backup
        mysqldump $database | gzip -c >$path/$database-$(date +%Y%m%d-%H%M%S).sql.gz
    ;;
    *)
        warn "no operation selected"
        debug "); you called me but didn't say anything"
        debug "now i feel useless"
    ;;
esac
