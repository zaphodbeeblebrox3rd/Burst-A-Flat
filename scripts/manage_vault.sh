#!/bin/bash

# Script to manage Ansible Vault for Munge keys and other secrets

VAULT_PASS_FILE=".vault_pass"
PASSWORDS_DIR="passwords"

# Create vault password file if it doesn't exist
if [ ! -f "$VAULT_PASS_FILE" ]; then
    echo "Creating vault password file..."
    openssl rand -base64 32 > "$VAULT_PASS_FILE"
    chmod 600 "$VAULT_PASS_FILE"
    echo "Vault password file created: $VAULT_PASS_FILE"
    echo "IMPORTANT: Keep this file secure and do not commit it to version control!"
fi

# Create passwords directory if it doesn't exist
if [ ! -d "$PASSWORDS_DIR" ]; then
    mkdir -p "$PASSWORDS_DIR"
    chmod 700 "$PASSWORDS_DIR"
    echo "Passwords directory created: $PASSWORDS_DIR"
fi

echo "Vault management setup complete."
echo "To encrypt a file: ansible-vault encrypt --vault-password-file $VAULT_PASS_FILE <file>"
echo "To decrypt a file: ansible-vault decrypt --vault-password-file $VAULT_PASS_FILE <file>"
echo "To view a file: ansible-vault view --vault-password-file $VAULT_PASS_FILE <file>"
