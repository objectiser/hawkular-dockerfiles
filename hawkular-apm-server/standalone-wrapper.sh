#!/bin/bash

# where are we located? usually, we are on $JBOSS_HOME/bin , along with the other scripts
DIRNAME=`dirname "$0"`

# we create only if there's no active users starting with 'admin'
grep "^admin" "${DIRNAME}/../standalone/configuration/application-users.properties" > /dev/null
RT=$?

if [ $RT -eq 0 ]; then
  echo "An admin user has already been found."
elif [ $RT -ne 1 ]; then
  echo "An error has been found when attempting to check if an admin user exists. Aborting."
  exit 1
else
  username="admin$(head /dev/random -c 512 | tr -dc A-Z-a-z-0-9 | head -c 7)"
  password=$(head /dev/random -c 512 | tr -dc A-Z-a-z-0-9 | head -c 17)
  ${DIRNAME}/add-user.sh -a -u "${username}" -p "${password}" -g read-write,read-only -s
  RT=$?
  if [ ${RT} -eq 0 ] ; then
    echo "------------------------------------"
    echo "ATTENTION ATTENTION ATTENTION ATTENTION"
    echo "We automatically created an admin user for you to access the Hawkular APM web interface:"
    echo "Username: ${username}"
    echo "Password: ${password}"
    echo "------------------------------------"
  else
    echo "------------------------------------"
    echo "ATTENTION ATTENTION ATTENTION ATTENTION"
    echo "We attempted to create an admin user for you to access the Hawkular APM web interface,"
    echo "but for some reason, we didn't succeed. You might need to enter the container manually"
    echo "and create one user as specified in the documentation."
    echo "Please, report it to the Hawkular APM team if you think this is a bug."
    echo "------------------------------------"
  fi
fi

${DIRNAME}/standalone.sh "$@"
