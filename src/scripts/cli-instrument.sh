#!/bin/bash
SOURCE_CONNECTOR_ID="${SOURCECONNECTOR}"
BASEIMAGE="${SOURCEIMAGE}"

# Call the shell script and pass input arguments
imageName=$("${XRAY_REQUEST}" "$SOURCE_CONNECTOR_ID" "$BASEIMAGE")


PROJECT_IMAGE_INSTRUMENTED="${imageName}.instrumented"
PROJECT_IMAGE_SLIMMED="${imageName}.slimxx"
BASEIMAGE="${imageName}"
IMAGE_PLATFORM="linux/amd64"
TARGET_CONNECTOR_ID="${CONNECTOR_ID}"

log_output=$(slim instrument \
  --platform="$IMAGE_PLATFORM" \
  --target-image-connector "$SOURCE_CONNECTOR_ID" \
  --instrumented-image-connector "$TARGET_CONNECTOR_ID" \
  --instrumented-image "$PROJECT_IMAGE_INSTRUMENTED" \
  --hardened-image-connector "$TARGET_CONNECTOR_ID" \
  --hardened-image "$PROJECT_IMAGE_SLIMMED" \
  --timeout=20m \
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