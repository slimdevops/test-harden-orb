#!/bin/bash
SOURCE_CONNECTOR_ID="dockerhub.public"
BASEIMAGE="${SOURCEIMAGE}"

# Call the shell script and pass input arguments
imageName=$("parseimage.sh" "$SOURCE_CONNECTOR_ID" "$BASEIMAGE")

IMAGE="${imageName}.instrumented"

echo "$IMAGE"
docker pull "$IMAGE"

eval "docker run -d --cap-add ALL --user root --name my-orb-project -p 9001:9001 $IMAGE"