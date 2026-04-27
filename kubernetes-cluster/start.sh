#!/bin/bash

openldes_images="
openldes/ldes-server:latest
openldes/ldi-orchestrator:latest
"

#export KUBECONFIG="./.kube/config"
./kind-with-registry.sh

echo "Retagging ... 🏷️"
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

echo "Installing Ingress-NGINX Controller ... 🎮"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for Ingress-NGINX Controller to be ready ..."
INGRESS_POD=$(kubectl get --namespace 'ingress-nginx' pod -o jsonpath="{.items[0].metadata.name}")
kubectl wait --for=condition=Ready --namespace 'ingress-nginx' "pod/${INGRESS_POD}" --timeout=1m0s
echo "Ingress-NGINX Controller is ready ... 👍"

echo "Installing OpenLDES Server ... 🔗"
helm install -f ./demo/server/values.yaml --wait --timeout 5m0s demo ../openldes-server
echo "OpenLDES Server installed ... 👍"

echo "Creating occupancy event stream and views ... 🌊"
./demo/deploy-server.sh
echo "Occupancy event stream and views created ... 👍"

curl -s http://openldes.local/occupancy > /dev/null
echo "All done 🥳! You can now access the OpenLDES Server's occupancy at http://openldes.local/occupancy"
