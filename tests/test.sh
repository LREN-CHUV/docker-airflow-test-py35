#!/usr/bin/env bash

set -e

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"

     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     cd -P "$( dirname "$SOURCE" )"
     pwd
}

cd "$(get_script_dir)"

if [ "$CIRCLECI" = true ] || groups $USER | grep &>/dev/null '\bdocker\b'; then
  DOCKER_COMPOSE="docker-compose"
else
  DOCKER_COMPOSE="sudo docker-compose"
fi

echo
echo "Test airflow-test-py35"
$DOCKER_COMPOSE test_airflow
$DOCKER_COMPOSE test_nose

# Cleanup
echo
$DOCKER_COMPOSE stop
$DOCKER_COMPOSE rm -f > /dev/null 2> /dev/null
