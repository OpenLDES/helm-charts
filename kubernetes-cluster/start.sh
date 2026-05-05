#!/bin/bash

OPENLDES_IMAGES="
openldes/ldes-server:4.0.0
openldes/ldi-orchestrator:3.1.1
"

LDES_SERVER_NAMESPACE="openldes-server"
LDIO_NAMESPACE="openldes-ldio"
INGRESS_NGINX_NAMESPACE="ingress-nginx"

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
$OPENLDES_IMAGES
EOF

echo "Installing Ingress-NGINX Controller ... 🎮"
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"

echo "Waiting for Ingress-NGINX Controller to be ready ..."
sleep 10
INGRESS_POD=$(kubectl get --namespace "${INGRESS_NGINX_NAMESPACE}" pod -o jsonpath="{.items[0].metadata.name}")
kubectl wait --for=condition=Ready --namespace "${INGRESS_NGINX_NAMESPACE}" "pod/${INGRESS_POD}" --timeout=1m0s
echo "Ingress-NGINX Controller is ready ... 👍"

echo "Installing OpenLDES Server ... 🔗"
helm install -f ./demo/server/values.yaml --wait --timeout 5m0s --create-namespace --namespace "${LDES_SERVER_NAMESPACE}" ldes ../charts/openldes-server
kubectl wait --for=condition=Ready --namespace "${LDES_SERVER_NAMESPACE}" "deployment/ldes-server" --timeout=2m0s
echo "OpenLDES Server installed ... 👍"

echo "Creating occupancy event stream and views ... 🌊"
./demo/create-occupancy-ldes.sh
echo "Occupancy event stream and views created ... 👍"

echo "Now deploying the LDI Orchestrator ... 🤖"
helm install -f ./demo/ldio/values.yaml --wait --timeout 5m0s --create-namespace --namespace "${LDIO_NAMESPACE}"  ldio ../charts/openldes-ldio
echo "LDI Orchestrator deployed ... 👍"

curl -s http://openldes.local/occupancy > /dev/null
echo "All done 🥳! You can now access the OpenLDES Server's occupancy at http://openldes.local/occupancy"
