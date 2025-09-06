# Deployment Guide

## Prerequisites

- Docker and Docker Compose installed
- [niabhail-tech-shared-infra](https://github.com/niabhail/niabhail-tech-shared-infra) deployed and running
- Domain name with DNS configured (managed by shared Caddy proxy)

## Environment Configuration

1. Copy environment template:
   ```bash
   cp .env.example .env
   ```

2. Generate security keys:
   ```bash
   ./scripts/generate-keys.sh
   ```
   
   **Important**: Copy the generated keys exactly as shown to your .env file.
   These keys are critical for n8n data encryption and JWT authentication.

3. Edit .env with your configuration:

- Update DOMAIN_NAME and SUBDOMAIN (must match shared Caddy routing)
- Add the generated N8N_ENCRYPTION_KEY and N8N_JWT_SECRET from step 2
- Set secure passwords for POSTGRES_PASSWORD and N8N_DB_PASSWORD

## Production Deployment

1. Ensure DNS points to your server IP
2. Run deployment script:
   ```bash
   ./scripts/deploy.sh
   ```
3. Monitor startup logs:
   ```bash
   docker-compose logs -f
   ```

## Verification

- Check all services are healthy: `docker-compose ps`
- Test web access: `https://n8n.yourdomain.com`
- Verify database connection: `docker-compose exec postgres psql -U n8n_app -d n8n_prod`

## Troubleshooting
### Security Key Issues
```bash
# If deploy fails with key validation errors:
# 1. Check keys exist in .env
grep "N8N_ENCRYPTION_KEY\|N8N_JWT_SECRET" .env

# 2. Regenerate if needed
./scripts/generate-keys.sh

# 3. Verify key length (32+ characters)
echo ${#N8N_ENCRYPTION_KEY}
echo ${#N8N_JWT_SECRET}
```

### Database Issues
```bash
# Check database logs
docker-compose logs postgres

# Test connection
docker-compose exec postgres pg_isready -U postgres

# Access database
docker-compose exec postgres psql -U postgres -d n8n_prod
```

### Routing Issues
```bash
# Check if shared infrastructure is running
docker network ls | grep niabhail-tech-network

# Verify domain resolves
nslookup your-domain.com

# SSL certificates are managed by shared Caddy proxy
# Check shared infrastructure logs for SSL issues
```

### n8n Issues
```bash
# Check n8n logs
docker-compose logs n8n

# Health check
docker-compose exec n8n wget -qO- http://localhost:5678/healthz
```
