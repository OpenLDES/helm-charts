#!/bin/bash

kind delete cluster --name openldes
docker stop kind-registry && docker rm kind-registry
