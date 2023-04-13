#!/bin/bash

# Accept input arguments
arg1=$1
arg2=$2

string="${arg1}/${arg2}"

match=$(echo "${string}" | grep -oP '^(?:([^/]+)/)?(?:([^/]+)/)?([^@:/]+)(?:[@:](.+))?$')

IFS='/' 
read -r -a parts <<< "$match"


namespace=${parts[1]}
repository=${parts[2]}

if [ -z "$repository" ]; then
  repository="${namespace}"
  namespace="library"
fi

if echo "$repository" | grep -q ":"; then
  IFS=':' read -ra arr <<< "$repository"
  tag=${arr[1]}
  repository=${arr[0]}
else
  tag="latest"
fi




if [ -z "$namespace" ]; then
  namespace="library"
fi




echo "${namespace}/${repository}:${tag}"

