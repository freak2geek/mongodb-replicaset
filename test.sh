#!/usr/bin/env bash

export PROCESS_WAIT_TIMEOUT=600000

function isRunningMongo() {
  local mongoUrl="${1}"
  local output=$(mongosh "${mongoUrl}" --eval "print('Connected to MongoDB')" 2>&1)
  echo $output
  if [[ $output == *"MongoServerSelectionError"* ]] || [[ $output == *"Connected to MongoDB"* ]]; then
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
    sleep 5
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

hostOne="$(echo "${MONGO_URL_ONE}" | sed 's/mongo:[^@]*@//')"
hostTwo="$(echo "${MONGO_URL_TWO}" | sed 's/mongo:[^@]*@//')"
hostThree="$(echo "${MONGO_URL_THREE}" | sed 's/mongo:[^@]*@//')"

mongosh $MONGO_URL_ONE --eval "rs.initiate({ _id: \"rs0\", members: [{ _id: 0, host: \"${hostOne}\" }, { _id: 1, host: \"${hostTwo}\" }, { _id: 2, host: \"${hostThree}\" }]})"
mongosh $MONGO_URL_ONE --eval "rs.status()"
