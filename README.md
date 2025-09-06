# n8n with Shared Infrastructure

Production-ready n8n automation platform with PostgreSQL database, integrated with niabhail-tech shared infrastructure.

## Features

- **PostgreSQL Database**: Scalable database instead of SQLite
- **Shared Infrastructure**: Uses niabhail-tech-network and shared Caddy proxy
- **Health Checks**: Service dependency management
- **Security**: Dedicated database user, encryption keys
- **Production Ready**: Logging, monitoring, restart policies
- **YAML Anchors**: Maintainable configuration
- **Enterprise Features**: Connection limits, extensions, proper permissions

## Prerequisites

**IMPORTANT**: This project requires [niabhail-tech-shared-infra](https://github.com/niabhail/niabhail-tech-shared-infra) to be deployed first, which provides:
- Shared Caddy reverse proxy with automatic SSL
- niabhail-tech-network Docker network  
- Centralized routing configuration

## Quick Start

1. **Deploy shared infrastructure first**:
   ```bash
   # Deploy https://github.com/niabhail/niabhail-tech-shared-infra
   git clone https://github.com/niabhail/niabhail-tech-shared-infra.git
   cd niabhail-tech-shared-infra
   # Follow deployment instructions
   ```

2. **Clone and configure this project**:
   ```bash
   git clone https://github.com/niabhail/niabhail-tech-n8n.git
   cd niabhail-tech-n8n
   cp .env.example .env
   ```

3. **Generate security keys**:
    ```bash
    ./scripts/generate-keys.sh
    ```
    Copy the output exactly to your `.env` file - these are critical for data security.

4. **Edit .env file** with your domain, generated keys, and database passwords

5. **Deploy n8n**:
    ```bash
    ./scripts/deploy.sh
    ```

## Configuration
Edit .env file with your settings:

- Domain configuration (DOMAIN_NAME, SUBDOMAIN) - must match shared Caddy routing
- Database passwords (secure these!)
- Security keys (use generate-keys.sh)
- Feature toggles (diagnostics, personalization)

## Architecture

- **Shared Infrastructure**: Caddy reverse proxy with automatic SSL (external)
- **n8n**: Workflow automation engine
- **PostgreSQL**: Production database with dedicated user
- **Docker Compose**: Orchestration with health checks and dependencies
- **Network**: Uses external niabhail-tech-network for routing

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

- **PostgreSQL instead of SQLite**
- **Shared infrastructure integration** - uses external Caddy and network
- **Health checks and service dependencies**
- **Enhanced security configuration**
- **Production logging and monitoring**
- **YAML anchors for maintainable configuration**
- **Automated database initialization**
- **Deployment and utility scripts**

## Future Enhancements
This enhanced stack is designed to accommodate:

- AI model integration (Ollama, etc.)
- Code execution environments
- Vector databases for AI workflows
- Additional automation services

## Related Projects

This n8n deployment is part of the niabhail-tech ecosystem:

- **[niabhail-tech-shared-infra](https://github.com/niabhail/niabhail-tech-shared-infra)** - Shared Caddy proxy and networking (required)
- **[niabhail-tech-site](https://github.com/niabhail/niabhail-tech-site)** - Main website
- **niabhail-tech-n8n** - This automation platform

## Support

For n8n-specific issues, check the [official n8n documentation](https://docs.n8n.io/) and [community forums](https://community.n8n.io/).