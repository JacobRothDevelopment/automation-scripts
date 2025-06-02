#!/bin/bash

# example: ./php-sqlite-model.sh -n Models\Db -D test/classes/db/ -p test/database.sqlite

# region consts
version="B 0.0.1"

debug_mode=0
dry_run_mode=0

namespace=""
database_path=""
directory="."

auto_create_message="
/*
* This file was created automatically
* Do not alter this file as it may interfere with data handling in your database
* Please only update this class by running the model creation script
*/"

# more here on colors:
# https://stackoverflow.com/q/5947742
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
cyan='\e[36m'
red='\e[31m'
green='\e[2;32m'
green_bg='\e[1;42m'
yellow='\e[93m'
no_color='\e[0m'

# https://www.sqlite.org/datatype3.html#affinity_name_examples
declare -A types_map=(
    [INT]=int
    [INTEGER]=int
    [TINYINT]=int
    [SMALLINT]=int
    [MEDIUMINT]=int
    [BIGINT]=int
    [UNSIGNED BIG INT]=int
    [INT2]=int
    [INT8]=int
    
    [CHARACTER]=string
    [VARCHAR]=string
    [VARYING CHARACTER]=string
    [NCHAR]=string
    [NATIVE CHARACTER]=string
    [NVARCHAR]=string
    [TEXT]=string
    [CLOB]=string
    
    [BLOB]=string
    
    [REAL]=float
    [DOUBLE]=float
    [DOUBLE PRECISION]=float
    [FLOAT]=float
    
    [NUMERIC]=float
    [DECIMAL]=float
    [BOOLEAN]=bool
    [DATE]=string
    [DATETIME]=string
)

declare -A nullable_map=(
    [0]="?"
    [1]=""
    [2]=""
)
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
options() { # TODO options
    echo "TODO options"
}
# endregion

# cspell:disable-next-line
while getopts ":n:D:p:drhvc" option; do
    case "${option}" in
        d) debug_mode=1 ;;
        D) directory=${OPTARG} ;;
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
        n) namespace=${OPTARG} ;;
        p) database_path=${OPTARG} ;;
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

# get current settings
sql_mode=$(sqlite3 $database_path ".mode") # example output: current output mode: list
STARTING_MODE="${sql_mode:21}"
debug "Starting mode: $STARTING_MODE"

# set relevant settings
activity "sqlite settings"
sql_mode=$(sqlite3 $database_path ".mode list")
sql_mode=$(sqlite3 $database_path ".headers off")

# sqlite3 /home/ubuntu/automation-scripts/test/database.sqlite "SELECT tbl_name FROM sqlite_master WHERE type = 'table' ORDER BY name;"
sql_tables=$(sqlite3 $database_path "SELECT tbl_name FROM sqlite_master WHERE type = 'table' ORDER BY name;")
readarray -t tables <<< "$sql_tables"

activity "creating php classes"
for i in "${!tables[@]}"; do
    table_name=${tables[$i]}
    debug "creating class for $table_name"

    file_path="$directory/$table_name.php"

    file_output="<?php\n$auto_create_message\n\n"
    if [[ -n "$namespace" ]]; then
        file_output+="namespace $namespace;\n\n"
    fi
    file_output+="class $table_name\n{\n"

    # sqlite3 /home/ubuntu/automation-scripts/test/database.sqlite "PRAGMA table_info(users);"
    sql_fields=$(sqlite3 $database_path "PRAGMA table_info($table_name);")
    readarray -t table_schema <<< "$sql_fields"

    for j in "${!table_schema[@]}"; do
        schema_details=${table_schema[$j]}
        readarray -t -d '|' field_info <<< $schema_details

        field_id=${field_info[0]}
        field_name=${field_info[1]}
        field_type=${field_info[2]}
        # field_type examples: INTEGER, TEXT, REAL, BLOB, NUMERIC(10,2), VARCHAR(255), BOOLEAN, etc
        # 's/[\(].*//g'     -> remove any size parameter
        field_type_name=$(echo $field_type | sed -e 's/[\(].*//g' | tr '[a-z]' '[A-Z]')
        # 's/^[^<\(>]*$//g' -> if there is no size parameter, delete everything
        # 's/.*[\(]//g'     -> remove everything up until the size parameter, including the paren
        # 's/[\)]//g'       -> remove the closing paren
        field_type_size=$(echo $field_type | sed -e 's/^[^<\(>]*$//g' -e 's/.*[\(]//g' -e 's/[\)]//g')
        field_not_null=${field_info[3]}
        field_default=${field_info[4]}
        field_pk=$(echo ${field_info[5]} | xargs) # remove trailing spaces

        nullable_key=$((field_not_null + field_pk))
        type_value=${types_map[$field_type_name]}
        nullable_value=${nullable_map[$nullable_key]}

        # if there is no valid type, remove nullable flag
        if [ -z $type_value ]; then
             nullable_value=""
        fi

        # debug "$field_id, $field_name, $field_type_name, $field_type_size, $field_not_null, $field_default, $field_pk"
        # debug "$field_name, $field_not_null, $field_pk, $nullable_value"
        file_output+="    public $nullable_value$type_value \$$field_name;\n"
    done
    file_output+="}"

    mkdir -p $directory
    echo -e "$file_output" > $file_path
done

# reset .mode settings back to original
activity "resetting .mode back to \"$STARTING_MODE\""
sql_mode=$(sqlite3 $database_path ".mode $STARTING_MODE")

success "process complete"
