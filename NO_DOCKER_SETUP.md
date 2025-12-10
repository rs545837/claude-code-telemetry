# Running Claude Code Telemetry WITHOUT Docker

This setup runs the telemetry bridge locally (Node.js) and uses Langfuse Cloud for the dashboard.

## ✅ What's Running

**NO Docker containers!**

- **Telemetry Bridge**: Node.js process on `http://localhost:4318`
- **Dashboard**: Langfuse Cloud at `https://cloud.langfuse.com`

## 🚀 Quick Start

### 1. Start the Telemetry Server

```bash
cd /Users/rohansharma/tracetest/claude-code-telemetry
npm start
```

Keep this terminal open.

### 2. Configure Claude (in a new terminal)

```bash
cd /Users/rohansharma/tracetest/claude-code-telemetry
source claude-telemetry.env

# Verify it's set:
echo $CLAUDE_CODE_ENABLE_TELEMETRY  # Should show: 1
echo $OTEL_EXPORTER_OTLP_ENDPOINT   # Should show: http://127.0.0.1:4318
```

### 3. Use Claude

```bash
claude "Create a hello world function in Python"
```

### 4. View Traces

Open your Langfuse Cloud dashboard:
- URL: https://cloud.langfuse.com
- Project: `my-organization` → `claude-code-telemetry`
- Navigate to **Traces** to see your Claude interactions

## 📋 Configuration

All configuration is in `.env`:

```bash
# Langfuse Cloud credentials
LANGFUSE_PUBLIC_KEY=pk-lf-f2f1bd70-4781-4693-876a-3bb05343367f
LANGFUSE_SECRET_KEY=sk-lf-2f5f7a3d-cccb-48e9-bf4b-88bfa0547f53
LANGFUSE_HOST=https://cloud.langfuse.com

# Server settings
OTLP_RECEIVER_PORT=4318
OTLP_RECEIVER_HOST=127.0.0.1
LOG_LEVEL=info
```

## 🔍 Verify Everything Works

```bash
# Check server health
curl http://localhost:4318/health

# Should return:
# {
#   "status": "healthy",
#   "langfuse": "connected",
#   ...
# }
```

## 🛑 Stop the Server

Press `Ctrl+C` in the terminal where `npm start` is running.

Or kill the process:
```bash
pkill -f "node src/server.js"
```

## 💡 Make Claude Telemetry Permanent

Add to your `~/.zshrc` (or `~/.bashrc`):

```bash
# Claude Code Telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_LOGS_EXPORTER=otlp
export OTEL_METRICS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=http/json
export OTEL_EXPORTER_OTLP_METRICS_PROTOCOL=http/json
export OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:4318
export OTEL_LOG_USER_PROMPTS=1
```

Then reload:
```bash
source ~/.zshrc  # or ~/.bashrc
```

## 🎯 What You Get

- ✅ Cost tracking per session and model
- ✅ Token usage (input, output, cached)
- ✅ Tool usage analytics
- ✅ Session grouping (1-hour windows)
- ✅ Complete conversation history
- ✅ Performance metrics

## 🆘 Troubleshooting

**Server won't start - "port in use":**
```bash
pkill -f "node src/server.js"
npm start
```

**No traces in Langfuse:**
1. Check server is running: `curl http://localhost:4318/health`
2. Verify Claude telemetry is enabled: `echo $CLAUDE_CODE_ENABLE_TELEMETRY`
3. Make sure you're in the terminal where you ran `source claude-telemetry.env`
4. Check Langfuse Cloud credentials in `.env`

**Want debug logs:**
```bash
LOG_LEVEL=debug npm start
```

## 📚 Files

- `.env` - Server configuration (Langfuse credentials)
- `claude-telemetry.env` - Claude environment variables
- `src/server.js` - Main telemetry server
- `package.json` - Dependencies

## 🌐 Architecture

```
Claude Code → OTLP (localhost:4318) → Telemetry Bridge (Node.js) → Langfuse Cloud
                                             ↓
                                    Parses & enriches data
                                    Groups into sessions
                                    Tracks costs & tokens
```

**Zero Docker required!** The telemetry bridge is pure Node.js, and Langfuse Cloud handles the dashboard.

