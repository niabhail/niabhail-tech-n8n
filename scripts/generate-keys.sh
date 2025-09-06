#!/bin/bash

echo "=== Generating Security Keys for n8n ==="
echo ""

# Generate encryption key (32 characters)
ENCRYPTION_KEY=$(openssl rand -hex 16)

# Generate JWT secret (64 characters)
JWT_SECRET=$(openssl rand -hex 32)

echo "🔑 Generated security keys:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY"
echo "N8N_JWT_SECRET=$JWT_SECRET"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Copy these lines to your .env file:"
echo "   1. Open .env in your editor: nano .env"
echo "   2. Add the two lines above to your .env file"  
echo "   3. Save and exit"
echo ""
echo "⚠️  IMPORTANT: Keep these keys secure and never commit them to version control"
echo ""
echo "✅ Next step: Run ./scripts/deploy.sh"
