#!/bin/bash

function usage() { echo "Usage: $0 -h host -d database -p port -u username -w password -t 'tests/*.sql'" 1>&2; exit 1; }

while getopts d:h:p:u:w:b:n:t: OPTION
do
  case $OPTION in
    d)
      DATABASE=$OPTARG
      ;;
    h)
      HOST=$OPTARG
      ;;
    p)
      PORT=$OPTARG
      ;;
    u)
      USER=$OPTARG
      ;;
    w)
      PASSWORD=$OPTARG
      ;;
    t)
      TESTS=$OPTARG
      ;;
    H)
      usage
      ;;
  esac
done

echo "Waiting for database..."
dockerize -timeout 240s -wait tcp://$HOST:$PORT
echo

echo "Running tests: $TESTS"
# install airflow-test-py35
PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -f /airflow-test-py35/sql/airflow-test-py35.sql > /dev/null 2>&1

rc=$?
# exit if airflow-test-py35 failed to install
if [[ $rc != 0 ]] ; then
  echo "pgTap was not installed properly. Unable to run tests!"
  exit $rc
fi
# run the tests
PGPASSWORD=$PASSWORD pg_prove -h $HOST -p $PORT -d $DATABASE -U $USER $TESTS
rc=$?
# uninstall airflow-test-py35
PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -f /airflow-test-py35/sql/uninstall_airflow-test-py35.sql > /dev/null 2>&1
# exit with return code of the tests
exit $rc
