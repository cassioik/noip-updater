#!/bin/bash

# This script removes the No-IP updater from Docker Swarm

echo "Removing No-IP updater stack from swarm..."
docker stack rm noip

echo "Waiting for stack to be removed (10 seconds)..."
sleep 10

echo "Removing secrets..."
docker secret rm noip_username noip_password noip_hostname

echo "Cleanup complete"
echo "If you want to leave swarm mode: docker swarm leave --force"
