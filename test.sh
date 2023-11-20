#!/usr/bin/env bash

# Check if MongoDB is running on the specified host and port
mongo --url $MONGO_URL_ONE --eval "print('Connected to MongoDB')"

if [ $? -eq 0 ]; then
  echo "MongoDB nodes are available."
else
  echo "MongoDB nodes are not available."
fi
