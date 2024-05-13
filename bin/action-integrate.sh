#!/bin/bash

ctrl_c() {
    printf "\n\n|------------------------------------------------------------------\n"
    printf "| Integration Pipeline: Exiting due to user interruption."
    printf "\n|------------------------------------------------------------------\n"
    exit 1
}

trap ctrl_c SIGINT

root_folder="$(realpath $(dirname $(realpath $0))/..)"
pipelines_folder="$root_folder/pipelines/integrate"

pipeline=default

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pipeline|-p)
            shift
            pipeline="$1"
            ;;
        --pipeline=*|-p=*)
            pipeline="${1#*=}"
            ;;
        *) # Ignore other arguments
            ;;
    esac
    shift
done

if ! [[ -f "$pipelines_folder/$pipeline.yml" ]]; then
    echo "Pipeline \"$pipelines_folder/$pipeline.yml\" not found"
    exit 1
fi

printf "\nIntegration Pipeline: Starting execution of \"$pipeline\"...\n"

steps_string=$(cat "$pipelines_folder/$pipeline.yml")

IFS=$'\n'
count=1

for line in $steps_string; do

    if [[ $line == '#'* ]]; then
        continue
    fi

    step="${line%%:*}"
    step="${step#- }"

    value="${line#*: }"

    if [[ -n $step ]] && [[ -n $value ]]; then
        steps_array[$count]=$step
        commands_array[$count]=$value
        ((count++))
    fi
done

bold=$(tput bold)
normal=$(tput sgr0)

for ((i=1; i<=${#steps_array[@]}; i++)); do
    step=${steps_array[$i]}

    printf "\n\033[0;35m|-----------------------------------------------\033[0m\n"
    printf "\033[0;35m| Step $i:\033[0m ${bold}$step${normal}"
    printf "\n\033[0;35m|-----------------------------------------------\033[0m\n"

    printf "\n"

    command=${commands_array[$i]}

    sh -c "$root_folder/bin/laracy.sh $command"

    printf "\n\033[0;35m[Step $i]:\033[0m ${bold}Completed!${normal}\n"
done

printf "\nIntegration Pipeline: \"$pipeline\" has finished its execution.\n\n"
