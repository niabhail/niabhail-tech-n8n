#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Deploying n8n Enhanced Stack ==="
echo "Project directory: $PROJECT_DIR"

# Change to project directory
cd "$PROJECT_DIR"

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found."
    echo "   Copy .env.example to .env and configure it:"
    echo "   cp .env.example .env && nano .env"
    exit 1
fi

# Source environment variables
source ".env"

echo "✓ Environment configuration loaded"
echo "  Domain: ${SUBDOMAIN}.${DOMAIN_NAME}"
echo "  Project: ${COMPOSE_PROJECT_NAME:-n8n}"

# Validate required environment variables
required_vars=("DOMAIN_NAME" "SUBDOMAIN" "POSTGRES_PASSWORD" "N8N_DB_PASSWORD" "N8N_ENCRYPTION_KEY" "N8N_JWT_SECRET")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: Required environment variable $var is not set"
        exit 1
    fi
done

# Export variables for envsubst
export SUBDOMAIN DOMAIN_NAME POSTGRES_PASSWORD N8N_DB_PASSWORD N8N_ENCRYPTION_KEY N8N_JWT_SECRET
echo "✓ Required environment variables validated"

# Check if Caddyfile exists
echo "Processing Caddyfile template..."
mkdir -p "caddy_config"

envsubst < "caddy_config/Caddyfile.template" > "caddy_config/Caddyfile"
echo "✓ Caddyfile processed for ${SUBDOMAIN}.${DOMAIN_NAME}"

# Verify the result
echo "Generated Caddyfile:"
cat "caddy_config/Caddyfile"

# Initialize database first
echo "🔄 Starting database initialization..."
docker-compose up -d postgres
sleep 10

# Wait for database to be healthy
echo "⏳ Waiting for database to be ready..."
timeout=60
while [ $timeout -gt 0 ]; do
    if docker-compose exec postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then
        echo "✓ Database is ready"
        break
    fi
    sleep 2
    timeout=$((timeout - 2))
done

if [ $timeout -le 0 ]; then
    echo "❌ Database failed to start within 60 seconds"
    docker-compose logs postgres
    exit 1
fi

# Deploy full stack
echo "🚀 Deploying complete stack..."
docker-compose up -d

echo "📊 Checking service health..."
sleep 10
docker-compose ps

echo "🎉 Deployment complete!"
echo ""
echo "Your n8n instance should be available at: https://${SUBDOMAIN}.${DOMAIN_NAME}"
echo ""
echo "To monitor logs: docker-compose logs -f"
echo "To check status: docker-compose ps"