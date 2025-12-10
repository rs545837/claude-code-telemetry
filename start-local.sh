#!/bin/bash

# Quick start script for running the telemetry server locally without Docker

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found!${NC}"
    echo ""
    echo "Please run setup first:"
    echo -e "${GREEN}   ./scripts/setup-local.sh${NC}"
    echo ""
    echo "Or create .env manually with:"
    echo "   LANGFUSE_PUBLIC_KEY=pk-lf-your-key"
    echo "   LANGFUSE_SECRET_KEY=sk-lf-your-key"
    echo "   LANGFUSE_HOST=http://localhost:3000"
    exit 1
fi

# Check if node_modules exists
if [ ! -d node_modules ]; then
    echo -e "${YELLOW}⚠️  Dependencies not installed!${NC}"
    echo "Installing dependencies..."
    npm install
fi

echo -e "${GREEN}🚀 Starting Claude Code Telemetry Server...${NC}"
echo ""

# Start the server
npm start

