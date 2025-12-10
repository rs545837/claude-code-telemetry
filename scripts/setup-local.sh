#!/bin/bash

# Claude Code Telemetry - Local Setup (No Docker)
# Sets up the telemetry server to run locally without Docker

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Claude Code Telemetry - Local Setup (No Docker)${NC}"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 18+ first.${NC}"
    echo "   Visit: https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}❌ Node.js version must be 18 or higher. Current version: $(node -v)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js $(node -v) detected${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm is not installed.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ npm $(npm -v) detected${NC}"
echo ""

# Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
npm install
echo ""

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${BLUE}📝 Creating .env file...${NC}"
    cat > .env <<'ENVEOF'
# Claude Code Telemetry Server Configuration
# Fill in your Langfuse credentials below

# Required: Langfuse API credentials
LANGFUSE_PUBLIC_KEY=pk-lf-your-public-key-here
LANGFUSE_SECRET_KEY=sk-lf-your-secret-key-here

# Optional: Langfuse host URL
# For Langfuse Cloud: https://cloud.langfuse.com
# For local: http://localhost:3000
LANGFUSE_HOST=http://localhost:3000

# Optional: Server configuration
OTLP_RECEIVER_PORT=4318
OTLP_RECEIVER_HOST=127.0.0.1
SESSION_TIMEOUT=3600000
MAX_REQUEST_SIZE=10485760

# Optional: Logging
LOG_LEVEL=info
NODE_ENV=production

# Optional: API key for securing the telemetry endpoint
API_KEY=

# Optional: Langfuse SDK configuration
LANGFUSE_FLUSH_AT=20
LANGFUSE_FLUSH_INTERVAL=10000
ENVEOF
    echo -e "${YELLOW}⚠️  Please edit .env and add your Langfuse credentials:${NC}"
    echo ""
    echo "   1. LANGFUSE_PUBLIC_KEY"
    echo "   2. LANGFUSE_SECRET_KEY"
    echo "   3. LANGFUSE_HOST (if not using localhost:3000)"
    echo ""
    echo -e "${BLUE}📋 Getting Langfuse credentials:${NC}"
    echo ""
    echo "   Option 1 - Langfuse Cloud (Recommended):"
    echo "   • Sign up at: https://cloud.langfuse.com"
    echo "   • Create a project"
    echo "   • Go to Settings > API Keys"
    echo "   • Copy Public Key and Secret Key"
    echo "   • Set LANGFUSE_HOST=https://cloud.langfuse.com"
    echo ""
    echo "   Option 2 - Self-hosted Langfuse:"
    echo "   • If you have Langfuse running locally, use:"
    echo "     LANGFUSE_HOST=http://localhost:3000"
    echo "   • Get API keys from your Langfuse dashboard"
    echo ""
    read -p "Press Enter when you've updated .env with your credentials..."
else
    echo -e "${GREEN}✅ .env file already exists${NC}"
fi

# Create Claude telemetry environment file
echo -e "${BLUE}📝 Creating claude-telemetry.env...${NC}"
cat > claude-telemetry.env <<EOF
# Add this to your shell profile (.bashrc, .zshrc, etc) or run before using Claude
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_LOGS_EXPORTER=otlp
export OTEL_METRICS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=http/json
export OTEL_EXPORTER_OTLP_METRICS_PROTOCOL=http/json
export OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:4318
export OTEL_LOG_USER_PROMPTS=1
EOF

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}🚀 Starting the telemetry server:${NC}"
echo ""
echo -e "${GREEN}   npm start${NC}"
echo ""
echo -e "${BLUE}📋 Or in development mode:${NC}"
echo ""
echo -e "${GREEN}   npm run dev${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}🔧 Configure Claude Code:${NC}"
echo ""
echo "1. In a NEW terminal, source the environment file:"
echo -e "${GREEN}   source claude-telemetry.env${NC}"
echo ""
echo "2. Test it works:"
echo -e "${GREEN}   claude \"What is 2+2?\"${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}💡 Tips:${NC}"
echo ""
echo "• The server runs on: http://127.0.0.1:4318"
echo "• Health check: http://127.0.0.1:4318/health"
echo "• View logs: The server will show incoming telemetry"
echo "• To make Claude telemetry permanent, add to ~/.zshrc or ~/.bashrc:"
echo -e "${GREEN}   source $(pwd)/claude-telemetry.env${NC}"
echo ""

