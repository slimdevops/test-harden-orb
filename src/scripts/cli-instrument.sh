#!/bin/bash
SOURCE_CONNECTOR="${SOURCE_CONNECTOR_ID}"
BASEIMAGE="${SOURCEIMAGE}"

string="${SOURCE_CONNECTOR}/${SOURCEIMAGE}"


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


PROJECT_IMAGE_INSTRUMENTED="${namespace}/${repository}:${tag}.instrumented"
PROJECT_IMAGE_SLIMMED="${namespace}/${repository}:${tag}.slimxx"
BASEIMAGE="${namespace}/${repository}:${tag}"
IMAGE_PLATFORM="linux/amd64"
TARGET_CONNECTOR="${TARGET_CONNECTOR_ID}"

log_output=$(slim instrument \
  --platform="$IMAGE_PLATFORM" \
  --target-image-connector "$SOURCE_CONNECTOR" \
  --instrumented-image-connector "$TARGET_CONNECTOR" \
  --instrumented-image "$PROJECT_IMAGE_INSTRUMENTED" \
  --hardened-image-connector "$TARGET_CONNECTOR" \
  --hardened-image "$PROJECT_IMAGE_SLIMMED" \
  --timeout=30m \
  "$BASEIMAGE" 2>&1 | tee /dev/stderr)

workflow_id=$(echo "$log_output" | grep -Eo 'workflow id: [a-zA-Z0-9\.]+')
workflow_id=${workflow_id#"workflow id: "}

if [[ $log_output =~ \[instrument\]\ instrumented ]]; then
  echo "The image has been successfully instrumented ($workflow_id)."
else
  echo "The image instrumentation failed ($workflow_id)."
  exit 1
fi
echo "export WORKFLOW_ID=$workflow_id" >> "$BASH_ENV"
echo "${workflow_id}" > my_var.txt