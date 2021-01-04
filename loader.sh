#!/usr/bin/env bash

#set -x

INC_CNT=0
MAX_CNT=50
while true; do
  sleep 1
  if [[ $INC_CNT == $MAX_CNT ]]; then
    break
  fi
  let "INC_CNT=INC_CNT+1"

  echo curl -d "watch_ids=kVQEW0SNFqE" -X POST http://98.234.161.130:30007/crawl
  curl -d "watch_ids=kVQEW0SNFqE" -X POST http://98.234.161.130:30007/crawl
done

