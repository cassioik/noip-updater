# No-IP DDNS Updater (IPv6)

This Docker-based solution automatically updates your No-IP domain with your current public IPv6 address.

## Setup

1. Clone this repository:
   ```
   git clone https://github.com/cassioik/noip-updater.git
   cd noip-updater
   ```

2. Set up Docker Secrets for secure credential management:
   ```
   mkdir -p secrets
   echo "your-username" > secrets/noip_username.txt
   echo "your-password" > secrets/noip_password.txt
   echo "your-domain.example.org" > secrets/noip_hostname.txt
   ```

3. Important: Modify the IPv6 subnet in docker-compose.yml to match your network configuration.

4. Build and start the container:
   ```
   docker-compose up -d
   ```

5. Check the logs:
   ```
   docker-compose logs -f
   ```

## Using Docker Secrets vs Environment Variables

This project supports two methods for providing No-IP credentials:

### 1. Docker Secrets (Recommended for Production)

Docker Secrets are the recommended method for production environments as they provide better security:
- Secrets are encrypted during transit when the swarm is used
- Secrets are stored in the container's filesystem in-memory only
- Secrets aren't exposed in container inspection commands, logs or environment variables

### 2. Environment Variables (For Development/Testing)

For quick development or testing, you can still use environment variables by modifying the docker-compose.yml:

```yaml
services:
  noip-updater:
    environment:
      - NOIP_USERNAME=your-username
      - NOIP_PASSWORD=your-password
      - NOIP_HOSTNAME=your-domain.example.org
      - UPDATE_INTERVAL=300
```

## Notes

- The updater will check your IPv6 address every 5 minutes (or as configured).
- Updates are only sent to No-IP when your IPv6 address actually changes.
- Your last IP address is stored persistently and survives container restarts.
- Logs are stored in the `logs` directory.
- Make sure your host system and Docker configuration supports IPv6.

## Requirements

- Docker with IPv6 networking enabled
- Host system with IPv6 connectivity

## Security

- Consider using Docker secrets for production environments instead of environment variables for sensitive data.
