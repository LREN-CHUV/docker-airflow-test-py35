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

if groups $USER | grep &>/dev/null '\bdocker\b'; then
  DOCKER="docker"
else
  DOCKER="sudo docker"
fi

echo
echo "Test airflow-test-py35"
$DOCKER run -i -t --rm --entrypoint "/usr/local/bin/airflow" hbpmip/airflow-test-py35:latest version
$DOCKER run -i -t --rm --entrypoint "/usr/local/bin/nosetests" hbpmip/airflow-test-py35:latest --version
