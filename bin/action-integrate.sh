#!/bin/bash

root_folder="$(realpath $(dirname $(realpath $0))/..)"
compose_file="$root_folder/compose.yml"
pipelines_folder="$root_folder/pipelines/integrate"

pipeline=default
build=cli

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pipeline|-p)
            shift
            pipeline="$1"
            ;;
        --pipeline=*|-p=*)
            pipeline="${1#*=}"
            ;;
        --build|-b)
            shift
            build="$1"
            ;;
        --build=*|-b=*)
            build="${1#*=}"
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

if [[ $build != "cli" ]] && [[ $build != "server" ]]; then
    echo "Invalid build option \"$build\". Choose between \"cli\" or \"server\""
    exit 1
fi

steps_string=$(cat "$pipelines_folder/$pipeline.yml")

IFS=$'\n'
count=0

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

primary_color="\033[0;35m"
end_color="\033[0m"

bold=$(tput bold)
end_bold=$(tput sgr0)

ctrl_c() {
    printf "\n${primary_color}${bold}Laracy Integrate:${end_bold}${end_color} Exiting due to user interruption\n\n"
    exit 1
}

trap ctrl_c SIGINT

printf "\n${primary_color}${bold}Laracy Integrate:${end_bold}${end_color} Executing ${bold}$pipeline${end_bold} pipeline with ${bold}$count${end_bold} steps on a ${bold}"$build"${end_bold}-based image\n\n"

docker compose -f "$compose_file" --profile integrate_$build up laracy_integrate_$build -d --build

for ((i=0; i<${#steps_array[@]}; i++)); do
    number=$(( $i + 1 ))
    step=${steps_array[$i]}
    command="${commands_array[$i]}"

    printf "\n${primary_color}${bold}Step $number:${end_bold}${end_color} $step\n\n"

    sh -c "docker compose -f \""$compose_file"\" exec laracy_integrate_$build sh -c \""$command"\""

    printf "\n${primary_color}${bold}Step $number:${end_bold}${end_color} ${bold}Completed${end_bold}\n"
done

printf "\n"

docker compose -f "$compose_file" --profile integrate_$build down laracy_integrate_$build

printf "\n${primary_color}${bold}Laracy Integrate:${end_bold}${end_color} Execution of ${bold}$pipeline${end_bold} pipeline has finished!\n\n"
