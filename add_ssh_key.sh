#!/bin/bash

# Script to generate an ed25519 key, add it to authorized_keys, and set permissions.
# Usage: ./add_ssh_key.sh <username> [password]

# Check if 'ssh-keygen' is installed (likely part of openssh-client)
if ! command -v ssh-keygen >/dev/null 2>&1; then
  echo "Error: ssh-keygen is not installed. Please install it (e.g., `sudo apt install openssh-client` or similar)."
  exit 1
fi

# Get username from command line argument
if [ -z "$1" ]; then
  echo "Usage: $0 <username> [password]"
  exit 1
fi
USERNAME="$1"

# Get password from command line argument (optional)
if [ -n "$2" ]; then
  PASSWORD="$2"
else
  # Use a blank password
  PASSWORD=""
  echo "Using NO Password: $PASSWORD"
fi

# Create the key pair using ssh-keygen
echo "Generating ed25519 key pair..."
SSH_KEY_DIR="/home/$USERNAME/.ssh"
mkdir -p "$SSH_KEY_DIR"

ssh-keygen -t ed25519 -f "$SSH_KEY_DIR/id_ed25519" -N "$PASSWORD"

# Get the public key from the file
ed25519_PUBLIC_KEY=$(cat "$SSH_KEY_DIR/id_ed25519.pub")

# Construct the authorized_keys entry with password
AUTHORIZED_KEY_ENTRY="$ed25519_PUBLIC_KEY : $PASSWORD"

# Determine the authorized_keys file path
AUTHORIZED_KEYS_FILE="$SSH_KEY_DIR/authorized_keys"

# Append the authorized key entry to the authorized_keys file
echo "Adding key to $AUTHORIZED_KEYS_FILE..."
echo "$AUTHORIZED_KEY_ENTRY" >> "$AUTHORIZED_KEYS_FILE"

# Set proper ownership and permissions
echo "Setting permissions..."
chown -R "$USERNAME:$USERNAME" $SSH_KEY_DIR
chmod 600 "$AUTHORIZED_KEYS_FILE"

echo "Key generation and setup complete for user $USERNAME."
echo "Remember to keep the password safe!"
