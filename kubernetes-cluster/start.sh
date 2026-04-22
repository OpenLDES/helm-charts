#!/bin/bash

openldes_images="
openldes/ldes-server:latest
openldes/ldi-orchestrator:latest
"

#export KUBECONFIG="./.kube/config"
./kind-with-registry.sh

echo "Retagging ..."
while IFS= read -r i; do
  [ -z "$i" ] && continue
  image_name=$(echo "$i" | cut -d: -f1)
  echo "     -- Pushing image $i to Kind registry"
  docker pull "$i"
  docker tag "$i" "localhost:5001/$i"
  docker push "localhost:5001/$i"
done <<EOF
$openldes_images
EOF

cd ../openldes-server


