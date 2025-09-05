# n8n Docker Enhanced

Production-ready n8n automation platform with PostgreSQL database, Caddy reverse proxy, and automatic SSL certificates.

## Features

- **PostgreSQL Database**: Scalable database instead of SQLite
- **Automatic SSL**: Let's Encrypt certificates via Caddy
- **Health Checks**: Service dependency management
- **Security**: Dedicated database user, encryption keys
- **Production Ready**: Logging, monitoring, restart policies
- **YAML Anchors**: Maintainable configuration
- **Enterprise Features**: Connection limits, extensions, proper permissions

## Quick Start

1. **Clone and configure**:
   ```bash
   git clone https://github.com/niabhail/n8n-docker-enhanced.git
   cd n8n-docker-enhanced
   cp .env.example .env
   ```

2. **Generate security keys** :
    ```bash
    ./scripts/generate-keys.sh
    ```

3. **Edit .env file** with your domain and generated keys

4. **Deploy**:
    ```bash
    ./scripts/deploy.sh
    ```

## Configuration
Edit .env file with your settings:

- Domain configuration (DOMAIN_NAME, SUBDOMAIN)
- Database passwords (secure these!)
- Security keys (use generate-keys.sh)
- Feature toggles (diagnostics, personalization)

## Architecture

- Caddy: Reverse proxy with automatic SSL
- n8n: Workflow automation engine
- PostgreSQL: Production database with dedicated user
- Docker Compose: Orchestration with health checks and dependencies

## Monitoring
```bash
# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Health check
docker-compose exec n8n wget -qO- http://localhost:5678/healthz

# Database access
docker-compose exec postgres psql -U postgres -d n8n_prod
```

## Security Features

- Dedicated database user with minimal privileges
- Encryption keys for n8n data protection
- Network isolation between services
- Health checks and restart policies
- Connection limits and proper PostgreSQL extensions

## Differences from Original

- PostgreSQL instead of SQLite
- Health checks and service dependencies
- Enhanced security configuration
- Production logging and monitoring
- YAML anchors for maintainable configuration
- Automated database initialization
- Deployment and utility scripts

## Future Enhancements
This enhanced stack is designed to accommodate:

- AI model integration (Ollama, etc.)
- Code execution environments
- Vector databases for AI workflows
- Additional automation services

## Upstream Repo Notes  

Self-hosting n8n requires technical knowledge, including:

* Setting up and configuring servers and containers
* Managing application resources and scaling
* Securing servers and applications
* Configuring n8n

Get up and running with n8n on the following platforms:

* [DigitalOcean tutorial](https://docs.n8n.io/hosting/server-setups/digital-ocean/)
* [Hetzner Cloud tutorial](https://docs.n8n.io/hosting/server-setups/hetzner/)

If you have questions after trying the tutorials, check out the [forums](https://community.n8n.io/).

n8n recommends self-hosting for expert users. Mistakes can lead to data loss, security issues, and downtime. If you aren't experienced at managing servers, n8n recommends [n8n Cloud](https://n8n.io/cloud/).