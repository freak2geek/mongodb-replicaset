#!/usr/bin/env bash

export PROCESS_WAIT_TIMEOUT=3600000

function isRunningMongo() {
  local mongoUrl="${1}"
  mongosh ${mongoUrl} --eval "print('Connected to MongoDB')"
  if [[ $? -eq 0 ]]; then
    return
  else
    return 1
  fi
}

function waitMongo() {
  local mongoUrl="${1}"
  local processWaitTimeoutSecs=$((PROCESS_WAIT_TIMEOUT / 1000))

  echo "Waiting mongo..."
  echo "- Url: ${mongoUrl}"

  local waitSecs=0
  while ! isRunningMongo "${mongoUrl}" && [[ "${waitSecs}" -lt "${processWaitTimeoutSecs}" ]]; do
    sleep 1
    waitSecs=$((waitSecs + 1))
  done

  if isRunningMongo "${mongoUrl}"; then
    echo "MongoDB is running. ${mongoUrl}"
    return
  else
    echo "Timout reached (${processWaitTimeoutSecs} seconds). Unable to wait for mongo instance."
    return 1
  fi
}

waitMongo $MONGO_URL_ONE
waitMongo $MONGO_URL_TWO
waitMongo $MONGO_URL_THREE
