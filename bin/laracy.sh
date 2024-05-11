#!/bin/bash

compose_file="$(dirname $(realpath $0))/../compose.yml"

if ! [[ -f $compose_file ]]; then
  echo "Laracy: the \"compose.yml\" file was not found"
  exit 1
fi

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

  if [[ $part1 == $part2 ]]; then
    docker compose -f "$compose_file" run --rm laracy_cli $@
  else
    docker compose -f "$compose_file" run --rm \
      $part1 laracy_cli $part2
  fi
}

function help() {
  printf "\nUsage: laracy COMMAND [SERVICE...]\n"
  printf "\nBuild, run and serve legacy Laravel projects\n"
  printf "\nCommon Commands:\n"
  printf "    php [OPTIONS]\n"
  printf "    composer [OPTIONS]\n"
  printf "    node [OPTIONS]\n"
  printf "    npm [OPTIONS]\n"
  printf "    python [OPTIONS]\n"
  printf "\nCommon Services:\n"
  printf "    cli [OPTIONS] COMMAND\n"
  printf "    server [OPTIONS] COMMAND\n"
  printf "    help\n"
  printf "\nAll commands relies on Docker Compose.\n"
  printf "\n"
}

case $1 in
"cli")
  cli ${@#cli}
  ;;
"server")
  server ${@#server}
  ;;
"help")
  help
  ;;
"-h")
  help
  ;;
"docker")
  docker $@
  ;;
*)
  run $@
  ;;
esac
