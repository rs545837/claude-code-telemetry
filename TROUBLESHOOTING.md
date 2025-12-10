# Troubleshooting: Traces Not Showing in Langfuse

If traces aren't appearing in Langfuse, follow these steps:

## Step 1: Verify Basic Setup

Run the debug script:
```bash
./scripts/debug-telemetry.sh
```

This will check:
- ✅ Server is running
- ✅ Langfuse credentials configured
- ✅ Langfuse connectivity
- ✅ Claude telemetry environment variables

## Step 2: Enable Debug Logging

1. **Update .env file:**
   ```bash
   LOG_LEVEL=debug
   ```

2. **Restart the server:**
   ```bash
   # Stop current server (Ctrl+C or):
   pkill -f "node src/server.js"
   
   # Start with debug logging:
   LOG_LEVEL=debug npm start
   ```

3. **In a NEW terminal, set Claude telemetry:**
   ```bash
   source claude-telemetry.env
   ```

4. **Use Claude:**
   ```bash
   claude "test message"
   ```

5. **Check server logs** - You should see:
   - `Received logs` messages
   - `Processing log record` with event names
   - `Session created` messages
   - Any warnings about missing session IDs

## Step 3: Common Issues

### Issue: "Log without session ID - cannot process"

**Problem:** The telemetry data doesn't have a `session.id` attribute.

**Solution:** This might be a Claude Code version issue. Check:
- Make sure you're using a recent version of Claude Code
- The telemetry format might have changed

**Workaround:** The code tries to create sessions from `user.id`/`user.email` + timestamp, but if those aren't present either, no session is created.

### Issue: Sessions created but no traces in Langfuse

**Problem:** Data is being processed but not sent to Langfuse.

**Check:**
1. Verify Langfuse credentials are correct
2. Check if Langfuse is accessible:
   ```bash
   curl http://localhost:3000/api/health
   # Or for Cloud:
   curl https://cloud.langfuse.com/api/health
   ```
3. Look for Langfuse SDK errors in server logs
4. Try manually flushing:
   ```bash
   # The server should auto-flush, but you can check the health endpoint
   curl http://localhost:4318/health
   ```

### Issue: No requests received

**Problem:** Claude isn't sending telemetry.

**Check:**
1. Verify environment variables are set:
   ```bash
   echo $CLAUDE_CODE_ENABLE_TELEMETRY
   echo $OTEL_EXPORTER_OTLP_ENDPOINT
   ```
2. Make sure you're in the terminal where you sourced `claude-telemetry.env`
3. Try restarting Claude Code / your terminal

### Issue: Wrong Langfuse Host

**Problem:** `.env` has `LANGFUSE_HOST=http://localhost:3000` but you're using Langfuse Cloud.

**Solution:** Update `.env`:
```bash
LANGFUSE_HOST=https://cloud.langfuse.com
LANGFUSE_PUBLIC_KEY=pk-lf-your-key
LANGFUSE_SECRET_KEY=sk-lf-your-key
```

Then restart the server.

## Step 4: Manual Testing

Test if the server can send to Langfuse:

```bash
# Check server health
curl http://localhost:4318/health

# Should show:
# {
#   "status": "healthy",
#   "langfuse": "connected",
#   "sessions": 0,
#   "requestCount": <number>
# }
```

## Step 5: Check Langfuse Dashboard

1. **For local Langfuse:** http://localhost:3000
2. **For Langfuse Cloud:** https://cloud.langfuse.com

Make sure you're looking at the correct project that matches your API keys.

## Still Not Working?

1. **Check server logs** for any error messages
2. **Verify Langfuse API keys** are correct in `.env`
3. **Try using Langfuse Cloud** instead of local (or vice versa)
4. **Check Claude Code version** - older versions might not send telemetry correctly
5. **Restart everything:**
   - Stop the telemetry server
   - Restart your terminal
   - Source `claude-telemetry.env` again
   - Start the server
   - Try using Claude

## Getting Help

If you're still stuck:
1. Run `./scripts/debug-telemetry.sh` and save the output
2. Check server logs with debug logging enabled
3. Note your Claude Code version
4. Note whether you're using Langfuse Cloud or self-hosted

