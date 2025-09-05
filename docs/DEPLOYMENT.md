# Deployment Guide

## Prerequisites

- Docker and Docker Compose installed
- Domain name with DNS configured
- SSL email for Let's Encrypt certificates

## Environment Configuration

1. Copy environment template:
   ```bash
   cp .env.example .env
   ```

2. Generate security keys:
   ```bash
   ./scripts/generate-keys.sh
   ```

3. Edit .env with your configuration:

- Update DOMAIN_NAME and SUBDOMAIN
- Set SSL_EMAIL for certificates
- Add generated encryption keys
- Set secure passwords

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
### Database Issues
```bash
# Check database logs
docker-compose logs postgres

# Test connection
docker-compose exec postgres pg_isready -U postgres

# Access database
docker-compose exec postgres psql -U postgres -d n8n_prod
```

### SSL Certificate Issues
```bash
# Check Caddy logs
docker-compose logs caddy

# Verify domain resolves
nslookup your-domain.com

# Check certificate status
docker-compose exec caddy caddy list-certificates
```

### n8n Issues
```bash
# Check n8n logs
docker-compose logs n8n

# Health check
docker-compose exec n8n wget -qO- http://localhost:5678/healthz
```
