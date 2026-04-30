SERVER_HOST=openldes.local
SERVER_PORT=80
SCRIPT_DIR=$(dirname "$(realpath $0)")
echo $SCRIPT_DIR
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams" -d "@${SCRIPT_DIR}/server/occupancy.ttl"
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d "@${SCRIPT_DIR}/server/occupancy.by-page.ttl"
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d "@${SCRIPT_DIR}/server/occupancy.by-time.ttl"
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d "@${SCRIPT_DIR}/server/occupancy.by-location.ttl"
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d "@${SCRIPT_DIR}/server/occupancy.by-parking.ttl"
