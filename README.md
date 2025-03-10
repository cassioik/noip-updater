# No-IP DDNS Updater (IPv6)

This Docker-based solution automatically updates your No-IP domain with your current public IPv6 address.

## Deployment Options

This project can be deployed in two ways:
1. As a standalone Docker container using Docker Compose
2. As a service in a Docker Swarm cluster

## Option 1: Standalone Docker Compose Setup

1. Clone this repository:
   ```
   git clone https://github.com/cassioik/noip-updater.git
   cd noip-updater
   ```

2. Run the setup script to configure your secrets:
   ```
   chmod +x setup-secrets.sh
   ./setup-secrets.sh
   ```

3. Build and start the container:
   ```
   docker compose up -d
   ```

4. Check the logs:
   ```
   docker compose logs -f
   ```

## Option 2: Docker Swarm Deployment

For production environments, Docker Swarm is recommended as it provides better secret management, high availability, and scalability.

1. Clone this repository:
   ```
   git clone https://github.com/cassioik/noip-updater.git
   cd noip-updater
   ```

2. Make the setup script executable and run it:
   ```
   chmod +x swarm-setup.sh
   ./swarm-setup.sh
   ```

3. Monitor your stack:
   ```
   # Check service status
   docker stack ps noip

   # Check logs
   docker service logs noip_noip-updater
   ```

### Swarm-Specific Features

When running in Swarm mode:
- Docker secrets are managed by the swarm and securely distributed to containers
- Service can be scaled if needed (though typically only one instance is required)
- Automatic restarts and failover provided by the swarm orchestrator

## Using Docker Secrets vs Environment Variables

This project supports two methods for providing No-IP credentials:

### 1. Docker Secrets (Recommended for Production)

Docker Secrets are the recommended method for production environments as they provide better security:
- Secrets are encrypted during transit when the swarm is used
- Secrets are stored in the container's filesystem in-memory only
- Secrets aren't exposed in container inspection commands, logs or environment variables

### 2. Environment Variables (For Development/Testing)

For quick development or testing, you can still use environment variables by modifying the docker-compose.yml.

## Notes

- The updater will check your IPv6 address every 5 minutes (or as configured).
- Updates are only sent to No-IP when your IPv6 address actually changes.
- Your last IP address is stored persistently and survives container restarts.
- Make sure your host system and Docker configuration supports IPv6.

## Requirements

- Docker with IPv6 networking enabled
- Host system with IPv6 connectivity
- Docker Swarm cluster (for swarm deployment)
