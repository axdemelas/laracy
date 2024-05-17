#!/bin/bash

root_folder="$(realpath $(dirname $(realpath $0))/..)"
bin_folder="$root_folder/bin"
compose_file="$root_folder/compose.yml"

if ! [[ -f $compose_file ]]; then
  echo "Laracy: the \"compose.yml\" file was not found"
  exit 1
fi

function action() {
  case $1 in
  "integrate")
    sh "$bin_folder/action-integrate.sh" ${@:2}
    ;;
  *)
    echo "Invalid action."
    ;;
  esac
}

function cli() {
  docker compose -f "$compose_file" --profile cli $@
}

function server() {
  docker compose -f "$compose_file" --profile server $@
}

function run() {
  args="$@"

  part1="${args% -- *}"
  part2="${args#* -- }"

  if [[ $part1 != $part2 ]]; then
    docker compose -f "$compose_file" run --rm $part1 laracy_cli $part2
    return
  fi

  if [[ $args == "php artisan serve"* ]]; then
    port="8000"
    host="0.0.0.0"

    while [[ $# -gt 0 ]]; do
      case "$1" in
      --port)
        shift
        port="$1"
        ;;
      --port=*)
        port="${1#*=}"
        ;;
      --host)
        shift
        host="$1"
        ;;
      --host=*)
        host="${1#*=}"
        ;;
      *)
        ;;
      esac
      shift
    done

    docker compose -f "$compose_file" run --rm -p $port:$port laracy_cli \
      php artisan serve --host=$host --port=$port
    return
  fi

  docker compose -f "$compose_file" run --rm laracy_cli $args
}

function help() {
  cat <<EOF

  Usage: laracy COMMAND [SERVICE...]

  Build, run and serve Laravel projects

  Common Commands:
      php [OPTIONS]
      composer [OPTIONS]
      node [OPTIONS]
      npm [OPTIONS]
      python [OPTIONS]

  Common Services:
      action [OPTIONS] COMMAND
      cli [OPTIONS] COMMAND
      server [OPTIONS] COMMAND
      help|-h|usage

  All commands relies on Docker Compose.

EOF
}

case $1 in
"action")
  action ${@:2}
  ;;
"cli")
  cli ${@:2}
  ;;
"server")
  server ${@:2}
  ;;
"help" | "-h" | "usage")
  help
  ;;
*)
  run $@
  ;;
esac
