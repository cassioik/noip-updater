#!/bin/bash

SECRETS_DIR="./secrets"
USERNAME="your-username"  # Default value, should be changed
PASSWORD="your-password"  # Default value, should be changed
HOSTNAME="your-domain.example.org"  # Default value, should be changed

# Create secrets directory if it doesn't exist
mkdir -p "$SECRETS_DIR"
echo "Created secrets directory"

# Prompt for credentials if in interactive mode
if [ -t 0 ]; then
    read -p "No-IP Username [$USERNAME]: " input_username
    read -p "No-IP Password [$PASSWORD]: " -s input_password
    echo "" # Newline after password input
    read -p "No-IP Hostname [$HOSTNAME]: " input_hostname

    # Use input if provided, otherwise use defaults
    USERNAME=${input_username:-$USERNAME}
    PASSWORD=${input_password:-$PASSWORD}
    HOSTNAME=${input_hostname:-$HOSTNAME}
fi

# Write secrets to files
echo "$USERNAME" > "$SECRETS_DIR/noip_username.txt"
echo "$PASSWORD" > "$SECRETS_DIR/noip_password.txt"
echo "$HOSTNAME" > "$SECRETS_DIR/noip_hostname.txt"

echo "Secrets created successfully!"
echo "- Username: $USERNAME"
echo "- Password: $(echo "$PASSWORD" | sed 's/./*/g')"
echo "- Hostname: $HOSTNAME"
echo ""
echo "You can now start the container with: docker compose up -d"

# Set proper permissions on secrets
chmod 600 "$SECRETS_DIR"/*.txt

# Add to .gitignore
if ! grep -q "secrets/" .gitignore; then
    echo "secrets/" >> .gitignore
    echo "Added secrets/ to .gitignore"
fi
