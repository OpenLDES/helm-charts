#!/bin/bash

kind delete cluster --name openldes
docker stop kind-registry && docker rm kind-registry
# Remove all images from the local Docker registry to free up space - be careful with this command as it will remove all Docker images from your local machine!
# docker image ls -q | xargs -I {} docker image rm -f {}
# Remove all Docker volumes to free up space - be careful with this command as it will remove all Docker volumes from your local machine!
docker volume ls -q | xargs -I {} docker volume rm -f {}
