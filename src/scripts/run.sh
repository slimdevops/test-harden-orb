#!/bin/bash
string="/${SOURCEIMAGE}"

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

IMAGE="${namespace}/${repository}:${tag}.instrumented"

echo "$IMAGE"
docker pull "$IMAGE"

eval "docker run -d --cap-add ALL --user root --name my-orb-project -p 9001:9001 $IMAGE"