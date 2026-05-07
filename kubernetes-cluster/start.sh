#!/bin/bash

OPENLDES_IMAGES="
openldes/ldes-server:4.0.0
openldes/ldi-orchestrator:3.1.1
"

LDES_SERVER_NAMESPACE="openldes-server"
LDIO_NAMESPACE="openldes-ldio"
INGRESS_NGINX_NAMESPACE="ingress-nginx"

wait_for_pod_ready() {
  local namespace="$1"
  local name="$2"
  local timeout="$3"
  echo "Waiting for pod with app.kubernetes.io/component='${name}' in namespace '${namespace}' to be ready..."
  sleep 10
  local POD=$(kubectl get --namespace "${namespace}" pod -l "app.kubernetes.io/component=${name}" -o jsonpath="{.items[0].metadata.name}")
  kubectl wait --for=condition=Ready --namespace "${namespace}" "pod/${POD}" --timeout="${timeout}"
}

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

#
#echo "Installing Ingress-NGINX Controller ... 🎮"
#kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
#
#echo "Waiting for Ingress-NGINX Controller to be ready ..."
#kubectl wait --namespace "${INGRESS_NGINX_NAMESPACE}" --for=condition=available deployment/ingress-nginx-controller --timeout=2m0s
#wait_for_pod_ready "${INGRESS_NGINX_NAMESPACE}" "controller" "2m0s"
#echo "Waiting for admission webhook to be ready ..."
#until kubectl get --namespace "${INGRESS_NGINX_NAMESPACE}" endpoints ingress-nginx-controller-admission -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null | grep -q .; do
#  echo "  Webhook endpoint not ready yet, retrying in 5s..."
#  sleep 5
#done
#echo "Webhook endpoint found, waiting for it to accept connections ..."
#until kubectl -n "${INGRESS_NGINX_NAMESPACE}" exec deploy/ingress-nginx-controller -- wget --spider --quiet --timeout=2 https://localhost:8443/healthz --no-check-certificate 2>/dev/null; do
#  echo "  Webhook not accepting connections yet, retrying in 5s..."
#  sleep 5
#done
#echo "Ingress-NGINX Controller is ready ... 👍"

echo "Installing OpenLDES Server ... 🔗"
helm install -f ./demo/server/values.yaml --wait --timeout 5m0s --create-namespace --namespace "${LDES_SERVER_NAMESPACE}" ldes ../charts/openldes-server
wait_for_pod_ready "${LDES_SERVER_NAMESPACE}" "ldes-server" "2m0s"
echo "OpenLDES Server installed ... 👍"

#echo "Creating occupancy event stream and views ... 🌊"
#./demo/create-occupancy-ldes.sh
#echo "Occupancy event stream and views created ... 👍"

echo "Now deploying the LDI Orchestrator ... 🤖"
helm install -f ./demo/ldio/values.yaml --wait --timeout 5m0s --create-namespace --namespace "${LDIO_NAMESPACE}"  ldio ../charts/openldes-ldio
echo "LDI Orchestrator deployed ... 👍"

curl -s http://localhost:8080/occupancy > /dev/null
echo "All done 🥳! You can now access the OpenLDES Server's occupancy at http://localhost:8080/occupancy"
