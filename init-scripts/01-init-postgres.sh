#!/bin/bash
set -e

echo "=== PostgreSQL Initialization for n8n ==="
echo "Database: ${POSTGRES_DB}"
echo "Main user: ${POSTGRES_USER}"
echo "n8n user: ${N8N_DB_USER}"

if [ -n "${N8N_DB_USER:-}" ] && [ -n "${N8N_DB_PASSWORD:-}" ]; then
    echo "Creating n8n application user: ${N8N_DB_USER}"
    
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        -- Create n8n user if it doesn't exist
        DO \$\$
        BEGIN
            IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${N8N_DB_USER}') THEN
                CREATE ROLE ${N8N_DB_USER} WITH 
                    LOGIN 
                    PASSWORD '${N8N_DB_PASSWORD}'
                    CONNECTION LIMIT 20;
                RAISE NOTICE 'Created user: ${N8N_DB_USER}';
            ELSE
                RAISE NOTICE 'User ${N8N_DB_USER} already exists';
                ALTER ROLE ${N8N_DB_USER} WITH PASSWORD '${N8N_DB_PASSWORD}';
            END IF;
        END
        \$\$;
        
        -- Grant comprehensive permissions for n8n operations
        GRANT CONNECT ON DATABASE ${POSTGRES_DB} TO ${N8N_DB_USER};
        GRANT USAGE, CREATE ON SCHEMA public TO ${N8N_DB_USER};
        
        -- Current objects
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${N8N_DB_USER};
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${N8N_DB_USER};
        GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO ${N8N_DB_USER};
        
        -- Future objects (critical for n8n table creation)
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${N8N_DB_USER};
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${N8N_DB_USER};
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO ${N8N_DB_USER};
        
        -- Create extensions that n8n might need
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        CREATE EXTENSION IF NOT EXISTS "pgcrypto";
        
        RAISE NOTICE 'Database initialization completed for n8n user: ${N8N_DB_USER}';
EOSQL

    echo "Testing database connection for n8n user..."
    PGPASSWORD="${N8N_DB_PASSWORD}" psql -h localhost -U "${N8N_DB_USER}" -d "${POSTGRES_DB}" -c "SELECT version();" > /dev/null
    echo "✓ Database connection test successful"
else
    echo "⚠️  WARNING: N8N_DB_USER or N8N_DB_PASSWORD not provided"
    echo "   Using PostgreSQL superuser - not recommended for production"
fi

echo "=== PostgreSQL initialization complete ==="
