#!/bin/bash
echo "Hardening workflow: $WORKFLOW_ID"

log_output=$(slim harden --timeout 30m  --id "$WORKFLOW_ID" 2>&1 | tee /dev/stderr)

if [[ $log_output =~ \[instrument\]\ completed ]]; then
  echo "The image has been successfully hardened ($WORKFLOW_ID)."
else
  echo "The image hardening failed ($WORKFLOW_ID)."
  exit 1
fi