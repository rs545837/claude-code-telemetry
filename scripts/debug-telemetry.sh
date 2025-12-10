#!/bin/bash

# Debug script for Claude Code Telemetry
# Helps diagnose why traces aren't showing in Langfuse

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Claude Code Telemetry Debugging${NC}"
echo ""

# 1. Check server status
echo -e "${BLUE}1. Checking telemetry server status...${NC}"
if curl -s http://localhost:4318/health > /dev/null 2>&1; then
    HEALTH=$(curl -s http://localhost:4318/health)
    echo -e "${GREEN}✅ Server is running${NC}"
    echo "   Health: $HEALTH"
else
    echo -e "${RED}❌ Server is NOT running on port 4318${NC}"
    echo "   Start it with: npm start"
    exit 1
fi
echo ""

# 2. Check .env configuration
echo -e "${BLUE}2. Checking .env configuration...${NC}"
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env file not found${NC}"
    exit 1
fi

LANGFUSE_HOST=$(grep "^LANGFUSE_HOST=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
LANGFUSE_PUBLIC_KEY=$(grep "^LANGFUSE_PUBLIC_KEY=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
LANGFUSE_SECRET_KEY=$(grep "^LANGFUSE_SECRET_KEY=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")

if [ -z "$LANGFUSE_PUBLIC_KEY" ] || [ "$LANGFUSE_PUBLIC_KEY" = "pk-lf-your-public-key-here" ]; then
    echo -e "${RED}❌ LANGFUSE_PUBLIC_KEY not configured in .env${NC}"
    exit 1
fi

if [ -z "$LANGFUSE_SECRET_KEY" ] || [ "$LANGFUSE_SECRET_KEY" = "sk-lf-your-secret-key-here" ]; then
    echo -e "${RED}❌ LANGFUSE_SECRET_KEY not configured in .env${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Langfuse credentials configured${NC}"
echo "   Host: $LANGFUSE_HOST"
echo "   Public Key: ${LANGFUSE_PUBLIC_KEY:0:20}..."
echo ""

# 3. Check Langfuse connectivity
echo -e "${BLUE}3. Checking Langfuse connectivity...${NC}"
if [[ "$LANGFUSE_HOST" == *"cloud.langfuse.com"* ]]; then
    if curl -s -o /dev/null -w "%{http_code}" "$LANGFUSE_HOST/api/health" | grep -q "200\|404"; then
        echo -e "${GREEN}✅ Langfuse Cloud is reachable${NC}"
    else
        echo -e "${YELLOW}⚠️  Cannot reach Langfuse Cloud${NC}"
        echo "   Check your internet connection"
    fi
elif [[ "$LANGFUSE_HOST" == *"localhost"* ]] || [[ "$LANGFUSE_HOST" == *"127.0.0.1"* ]]; then
    if curl -s "$LANGFUSE_HOST/api/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Local Langfuse is running${NC}"
    else
        echo -e "${RED}❌ Local Langfuse is NOT running on $LANGFUSE_HOST${NC}"
        echo "   You need to start Langfuse first, or use Langfuse Cloud"
        echo "   For Langfuse Cloud, update .env:"
        echo "   LANGFUSE_HOST=https://cloud.langfuse.com"
    fi
fi
echo ""

# 4. Check Claude telemetry environment
echo -e "${BLUE}4. Checking Claude telemetry environment...${NC}"
if [ -z "$CLAUDE_CODE_ENABLE_TELEMETRY" ]; then
    echo -e "${RED}❌ CLAUDE_CODE_ENABLE_TELEMETRY is not set${NC}"
    echo "   Run: source claude-telemetry.env"
    echo "   Or add to your shell profile"
else
    echo -e "${GREEN}✅ CLAUDE_CODE_ENABLE_TELEMETRY=$CLAUDE_CODE_ENABLE_TELEMETRY${NC}"
fi

if [ -z "$OTEL_EXPORTER_OTLP_ENDPOINT" ]; then
    echo -e "${RED}❌ OTEL_EXPORTER_OTLP_ENDPOINT is not set${NC}"
    echo "   Should be: http://127.0.0.1:4318"
else
    echo -e "${GREEN}✅ OTEL_EXPORTER_OTLP_ENDPOINT=$OTEL_EXPORTER_OTLP_ENDPOINT${NC}"
fi

if [ -z "$OTEL_LOGS_EXPORTER" ]; then
    echo -e "${RED}❌ OTEL_LOGS_EXPORTER is not set${NC}"
else
    echo -e "${GREEN}✅ OTEL_LOGS_EXPORTER=$OTEL_LOGS_EXPORTER${NC}"
fi

if [ -z "$OTEL_METRICS_EXPORTER" ]; then
    echo -e "${RED}❌ OTEL_METRICS_EXPORTER is not set${NC}"
else
    echo -e "${GREEN}✅ OTEL_METRICS_EXPORTER=$OTEL_METRICS_EXPORTER${NC}"
fi
echo ""

# 5. Check server logs for recent activity
echo -e "${BLUE}5. Recent server activity...${NC}"
HEALTH_DATA=$(curl -s http://localhost:4318/health)
REQUESTS=$(echo $HEALTH_DATA | grep -o '"requestCount":[0-9]*' | cut -d':' -f2)
ERRORS=$(echo $HEALTH_DATA | grep -o '"errorCount":[0-9]*' | cut -d':' -f2)
SESSIONS=$(echo $HEALTH_DATA | grep -o '"sessions":[0-9]*' | cut -d':' -f2)

echo "   Total requests: $REQUESTS"
echo "   Errors: $ERRORS"
echo "   Active sessions: $SESSIONS"

if [ "$REQUESTS" = "0" ]; then
    echo -e "${YELLOW}⚠️  No requests received yet${NC}"
    echo "   Make sure Claude telemetry env vars are set and try using Claude"
elif [ "$ERRORS" != "0" ]; then
    echo -e "${RED}❌ There are errors! Check server logs${NC}"
fi
echo ""

# 6. Recommendations
echo -e "${BLUE}6. Recommendations:${NC}"
echo ""

if [[ "$LANGFUSE_HOST" == *"localhost"* ]] || [[ "$LANGFUSE_HOST" == *"127.0.0.1"* ]]; then
    echo -e "${YELLOW}⚠️  You're using localhost:3000 for Langfuse${NC}"
    echo "   If you don't have Langfuse running locally, switch to Langfuse Cloud:"
    echo "   1. Sign up at https://cloud.langfuse.com"
    echo "   2. Get API keys from Settings > API Keys"
    echo "   3. Update .env:"
    echo "      LANGFUSE_HOST=https://cloud.langfuse.com"
    echo "      LANGFUSE_PUBLIC_KEY=pk-lf-your-key"
    echo "      LANGFUSE_SECRET_KEY=sk-lf-your-key"
    echo "   4. Restart the server: npm start"
    echo ""
fi

if [ -z "$CLAUDE_CODE_ENABLE_TELEMETRY" ]; then
    echo -e "${YELLOW}⚠️  Claude telemetry not enabled${NC}"
    echo "   In the terminal where you run Claude, execute:"
    echo "   source claude-telemetry.env"
    echo "   Then try: claude \"test\""
    echo ""
fi

echo -e "${GREEN}✅ Debug complete!${NC}"

