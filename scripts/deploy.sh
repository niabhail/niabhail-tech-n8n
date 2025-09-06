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
required_vars=("POSTGRES_PASSWORD" "N8N_DB_PASSWORD" "N8N_ENCRYPTION_KEY" "N8N_JWT_SECRET")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: Required environment variable $var is not set"
        if [[ "$var" == "N8N_ENCRYPTION_KEY" || "$var" == "N8N_JWT_SECRET" ]]; then
            echo "   Generate security keys with: ./scripts/generate-keys.sh"
            echo "   Then copy the output to your .env file"
        fi
        exit 1
    fi
done

# Additional validation for security keys format
if [[ ${#N8N_ENCRYPTION_KEY} -lt 32 ]]; then
    echo "❌ Error: N8N_ENCRYPTION_KEY must be at least 32 characters"
    echo "   Generate new keys with: ./scripts/generate-keys.sh"
    exit 1
fi

if [[ ${#N8N_JWT_SECRET} -lt 32 ]]; then
    echo "❌ Error: N8N_JWT_SECRET must be at least 32 characters"
    echo "   Generate new keys with: ./scripts/generate-keys.sh"
    exit 1
fi

echo "✓ Required environment variables validated"

# Check that shared infrastructure is available
echo "🔍 Checking shared infrastructure dependencies..."

# Check if niabhail-tech-network exists
if ! docker network ls --format "table {{.Name}}" | grep -q "^niabhail-tech-network$"; then
    echo "❌ Error: niabhail-tech-network not found"
    echo "   Deploy niabhail-tech-shared-infra first:"
    echo "   https://github.com/niabhail/niabhail-tech-shared-infra"
    exit 1
fi

echo "✓ niabhail-tech-network found"

# Validate domain configuration
if [ -z "$DOMAIN_NAME" ] || [ -z "$SUBDOMAIN" ]; then
    echo "❌ Error: DOMAIN_NAME and SUBDOMAIN must be set"
    echo "   These should match your shared Caddy routing configuration"
    exit 1
fi

echo "✓ Shared infrastructure dependencies verified"
echo "  Target URL: https://${SUBDOMAIN}.${DOMAIN_NAME}"
echo "  NOTE: Ensure routing rules are configured in shared Caddy proxy"

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
echo "  ⚠️  IMPORTANT: Configure routing in shared Caddy proxy if not already done"
echo ""
echo "Next steps:"
echo "  1. Configure Caddy routing: ${SUBDOMAIN}.${DOMAIN_NAME} -> n8n:5678"
echo "  2. Test access: curl -I https://${SUBDOMAIN}.${DOMAIN_NAME}"
echo "  3. Monitor logs: docker-compose logs -f"
echo "  4. Check status: docker-compose ps"