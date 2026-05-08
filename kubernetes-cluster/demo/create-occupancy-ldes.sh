SERVER_HOST=localhost
SERVER_PORT=8080
SCRIPT_DIR=$(dirname "$(realpath $0)")
echo $SCRIPT_DIR


while [[ "$(curl --location --head --silent --output /dev/null --write-out '%{response_code}' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams")" != "200" ]]; do
  echo "Waiting for the OpenLDES Server and Nginx Ingress Controller to be ready ..."
  sleep 5
done


curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams" -d "@${SCRIPT_DIR}/server/occupancy.ttl"
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d "@${SCRIPT_DIR}/server/occupancy.by-page.ttl"
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d "@${SCRIPT_DIR}/server/occupancy.by-time.ttl"
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d "@${SCRIPT_DIR}/server/occupancy.by-location.ttl"
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d "@${SCRIPT_DIR}/server/occupancy.by-parking.ttl"
