SERVER_HOST=openldes.local
SERVER_PORT=80

curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams" -d '@./server/occupancy.ttl'
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d '@./server/occupancy.by-page.ttl'
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d '@./server/occupancy.by-time.ttl'
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d '@./server/occupancy.by-location.ttl'
curl -X POST -H 'content-type: text/turtle' "http://${SERVER_HOST}:${SERVER_PORT}/admin/api/v1/eventstreams/occupancy/views" -d '@./server/occupancy.by-parking.ttl'"]
