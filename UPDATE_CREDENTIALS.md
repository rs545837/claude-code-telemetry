# Update Langfuse Credentials

## The Problem

Your current API keys are invalid and giving 401 Unauthorized errors:
```
[Langfuse SDK] 401: Unauthorized. Invalid credentials.
```

## The Solution

### Step 1: Get Your Real API Keys

1. **Login to Langfuse Cloud:**
   https://cloud.langfuse.com

2. **Navigate to API Keys:**
   - Click on your project: `my-organization` → `claude-code-telemetry`
   - Go to **Settings** (gear icon) → **API Keys**

3. **Copy the keys:**
   - Public Key (starts with `pk-lf-`)
   - Secret Key (starts with `sk-lf-`)

### Step 2: Update .env File

Edit `/Users/rohansharma/tracetest/claude-code-telemetry/.env`:

```bash
cd /Users/rohansharma/tracetest/claude-code-telemetry
nano .env
# Or: code .env
```

Replace with YOUR actual keys:
```bash
LANGFUSE_PUBLIC_KEY=pk-lf-YOUR-ACTUAL-PUBLIC-KEY-HERE
LANGFUSE_SECRET_KEY=sk-lf-YOUR-ACTUAL-SECRET-KEY-HERE
LANGFUSE_HOST=https://cloud.langfuse.com
```

### Step 3: Restart Server

```bash
npm start
```

### Step 4: Test

```bash
# In another terminal
source claude-telemetry.env
claude "test message"

# Stop server to flush data:
pkill -SIGTERM -f "node src/server.js"
```

### Step 5: Check Langfuse

Go to https://cloud.langfuse.com and check the Traces page.

---

## Alternative: Use Local Langfuse (requires Docker)

If you can't get Langfuse Cloud keys, use local Langfuse:

```bash
# Start local Langfuse
docker compose -f langfuse-official/docker-compose.yml -f docker-compose.langfuse.yml --env-file .env.langfuse up -d

# Update .env to use local credentials
cat > .env <<'EOF'
LANGFUSE_PUBLIC_KEY=pk-lf-396f8f782dc24159aa34601b1e326a95
LANGFUSE_SECRET_KEY=sk-lf-24336f499d3406b47402838710d9c914
LANGFUSE_HOST=http://localhost:3000
OTLP_RECEIVER_PORT=4318
OTLP_RECEIVER_HOST=127.0.0.1
LOG_LEVEL=info
EOF

# Restart server
npm start

# Access at: http://localhost:3000
# Login: admin-1765282773@claude-telemetry.local
# Password: zSVKCfamXRZIRuv/
```

This uses your local Langfuse credentials which are valid.

