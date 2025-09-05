#!/bin/bash

echo "=== Generating Security Keys ==="

# Generate encryption key (32 characters)
ENCRYPTION_KEY=$(openssl rand -hex 16)
echo "N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY"

# Generate JWT secret (64 characters)
JWT_SECRET=$(openssl rand -hex 32)
echo "N8N_JWT_SECRET=$JWT_SECRET"

echo ""
echo "Add these to your .env file!"
