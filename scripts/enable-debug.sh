#!/bin/bash

# Enable debug logging temporarily to see what's being received

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔍 Enabling Debug Logging${NC}"
echo ""

# Check if server is running
if ! pgrep -f "node src/server.js" > /dev/null; then
    echo -e "${YELLOW}Server is not running. Start it first with: npm start${NC}"
    exit 1
fi

echo -e "${YELLOW}⚠️  To enable debug logging, you need to restart the server with:${NC}"
echo ""
echo -e "${GREEN}LOG_LEVEL=debug npm start${NC}"
echo ""
echo "Or update .env file:"
echo "  LOG_LEVEL=debug"
echo ""
echo "Then restart the server to see detailed logs of what's being received."
echo ""
echo -e "${BLUE}Current .env LOG_LEVEL:${NC}"
grep "^LOG_LEVEL=" .env 2>/dev/null || echo "Not set (defaults to 'info')"

