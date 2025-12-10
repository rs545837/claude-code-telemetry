# Setting Up Claude Code Telemetry Without Docker

This guide walks you through setting up the telemetry bridge to run locally without Docker. This is ideal if you:
- Prefer not to use Docker
- Want to run just the telemetry bridge (not the full Langfuse stack)
- Already have Langfuse running (Cloud or self-hosted)
- Want easier debugging and development

## Prerequisites

- **Node.js 18+** - [Download here](https://nodejs.org/)
- **npm** (comes with Node.js)
- **Claude Code CLI** - Must have `claude` command available
- **Langfuse instance** - Either:
  - **Langfuse Cloud** (easiest): Sign up at https://cloud.langfuse.com
  - **Self-hosted Langfuse**: Your own instance running somewhere

## Quick Setup (Automated)

The easiest way to get started:

```bash
# Clone the repository
git clone https://github.com/lainra/claude-code-telemetry
cd claude-code-telemetry

# Run the automated setup script
./scripts/setup-local.sh
```

The script will:
1. Check Node.js version
2. Install npm dependencies
3. Create a `.env` file from template
4. Guide you through adding Langfuse credentials
5. Create the Claude telemetry environment file

Then:
```bash
# Start the server
npm start

# In another terminal, configure Claude
source claude-telemetry.env

# Test it
claude "What is 2+2?"
```

## Manual Setup

If you prefer to set things up manually:

### Step 1: Install Dependencies

```bash
npm install
```

### Step 2: Configure Environment Variables

Create a `.env` file in the project root:

```bash
cat > .env <<EOF
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
LOG_LEVEL=info
NODE_ENV=production
EOF
```

**Getting Langfuse Credentials:**

1. **If using Langfuse Cloud:**
   - Sign up at https://cloud.langfuse.com
   - Create a project
   - Go to Settings > API Keys
   - Copy the Public Key and Secret Key
   - Set `LANGFUSE_HOST=https://cloud.langfuse.com`

2. **If using self-hosted Langfuse:**
   - Log into your Langfuse dashboard
   - Go to Settings > API Keys
   - Copy the Public Key and Secret Key
   - Set `LANGFUSE_HOST` to your Langfuse URL (e.g., `http://localhost:3000`)

### Step 3: Create Claude Telemetry Environment File

```bash
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
```

### Step 4: Start the Telemetry Server

```bash
# Production mode
npm start

# Development mode (with debug logging)
npm run dev
```

You should see:
```
🚀 Claude Code Telemetry Server Started!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Server: http://127.0.0.1:4318
✅ Health: http://127.0.0.1:4318/health
✅ Langfuse: http://localhost:3000
```

### Step 5: Configure Claude Code

In a **new terminal** (keep the server running):

```bash
# Source the telemetry environment
source claude-telemetry.env

# Or add to your shell profile to make it permanent:
# echo "source $(pwd)/claude-telemetry.env" >> ~/.zshrc  # or ~/.bashrc
```

### Step 6: Test It Works

```bash
claude "What is 2+2?"
```

Check the server logs - you should see telemetry data being received. Then check your Langfuse dashboard to see the trace!

## Running the Server

### Production Mode
```bash
npm start
```

### Development Mode (with debug logging)
```bash
npm run dev
```

### Background (using nohup)
```bash
nohup npm start > telemetry.log 2>&1 &
```

### Background (using PM2 - recommended for production)
```bash
# Install PM2 globally
npm install -g pm2

# Start with PM2
pm2 start src/server.js --name claude-telemetry

# View logs
pm2 logs claude-telemetry

# Stop
pm2 stop claude-telemetry

# Restart
pm2 restart claude-telemetry
```

## Verifying It Works

### 1. Check Server Health

```bash
curl http://localhost:4318/health
```

Should return:
```json
{
  "status": "healthy",
  "uptime": 123.45,
  "activeSessions": 0,
  "requests": 5,
  "errors": 0
}
```

### 2. Check Server Logs

When you run `claude`, you should see logs like:
```
{"level":30,"time":1234567890,"msg":"Received telemetry data","type":"logs"}
{"level":30,"time":1234567890,"msg":"Session created","sessionId":"..."}
```

### 3. Check Langfuse Dashboard

1. Open your Langfuse dashboard
2. Go to Traces
3. You should see traces appearing when you use Claude

## Troubleshooting

### Server won't start

**Error: "LANGFUSE_PUBLIC_KEY is required"**
- Make sure your `.env` file exists and has the correct credentials
- Check that `.env` is in the project root directory

**Error: "EADDRINUSE: address already in use"**
- Another process is using port 4318
- Change `OTLP_RECEIVER_PORT` in `.env` to a different port
- Update `OTEL_EXPORTER_OTLP_ENDPOINT` in `claude-telemetry.env` to match

### No telemetry data received

1. **Check Claude is configured:**
   ```bash
   echo $CLAUDE_CODE_ENABLE_TELEMETRY
   # Should output: 1
   ```

2. **Check server is running:**
   ```bash
   curl http://localhost:4318/health
   ```

3. **Check endpoint matches:**
   ```bash
   echo $OTEL_EXPORTER_OTLP_ENDPOINT
   # Should output: http://127.0.0.1:4318
   ```

4. **Check server logs** for errors

### Telemetry received but not showing in Langfuse

1. **Verify Langfuse credentials** in `.env`
2. **Check Langfuse host URL** is correct
3. **Check Langfuse is accessible:**
   ```bash
   curl https://cloud.langfuse.com/api/health
   # Or for local: curl http://localhost:3000/api/health
   ```
4. **Check server logs** for Langfuse API errors

### Permission denied errors

Make the setup script executable:
```bash
chmod +x scripts/setup-local.sh
```

## Configuration Options

All configuration is done via environment variables in `.env`:

| Variable | Default | Description |
|----------|---------|-------------|
| `LANGFUSE_PUBLIC_KEY` | (required) | Langfuse public API key |
| `LANGFUSE_SECRET_KEY` | (required) | Langfuse secret API key |
| `LANGFUSE_HOST` | `http://localhost:3000` | Langfuse API URL |
| `OTLP_RECEIVER_PORT` | `4318` | Port to listen on |
| `OTLP_RECEIVER_HOST` | `127.0.0.1` | Host to bind to |
| `SESSION_TIMEOUT` | `3600000` | Session timeout in ms (1 hour) |
| `MAX_REQUEST_SIZE` | `10485760` | Max request size in bytes (10MB) |
| `LOG_LEVEL` | `info` | Logging level (debug, info, warn, error) |
| `NODE_ENV` | `production` | Environment mode |
| `API_KEY` | (optional) | API key to secure the endpoint |
| `LANGFUSE_FLUSH_AT` | `20` | Flush batch size |
| `LANGFUSE_FLUSH_INTERVAL` | `10000` | Flush interval in ms |

## Next Steps

- Read [Environment Variables Guide](ENVIRONMENT_VARIABLES.md) for detailed configuration
- Read [Telemetry Guide](TELEMETRY_GUIDE.md) to understand the data format
- Check the [Testing Guide](TESTING.md) to test your setup

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review server logs for error messages
3. Open an issue on GitHub with:
   - Error messages
   - Server logs
   - Your configuration (without secrets!)

