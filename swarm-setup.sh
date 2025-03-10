#!/bin/bash

# This script helps set up the No-IP updater on Docker Swarm

# Check if Docker is running in swarm mode
if ! docker info | grep -q "Swarm: active"; then
    echo "Docker is not running in swarm mode. Initializing swarm..."
    docker swarm init --advertise-addr $(hostname -i | awk '{print $1}')
else
    echo "Docker swarm is already active"
fi

# Set up secrets
read -p "No-IP Username: " USERNAME
read -p "No-IP Password: " -s PASSWORD
echo "" # Newline after password input
read -p "No-IP Hostname: " HOSTNAME

# Create Docker secrets
echo "Creating Docker secrets..."
echo "$USERNAME" | docker secret create noip_username -
echo "$PASSWORD" | docker secret create noip_password -
echo "$HOSTNAME" | docker secret create noip_hostname -

# Build the image
echo "Building Docker image..."
docker build -t noip-updater:latest .

# Deploy the stack
echo "Deploying the No-IP updater stack..."
docker stack deploy -c stack.yml noip

echo "No-IP updater has been deployed to the swarm"
echo "Use 'docker stack ps noip' to check the status of the services"
echo "Use 'docker service logs noip_noip-updater' to check the logs"
