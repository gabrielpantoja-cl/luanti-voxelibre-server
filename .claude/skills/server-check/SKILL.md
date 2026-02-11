---
name: server-check
description: Check Wetlands server status, logs, and health. Use when diagnosing issues, checking if server is running, or reviewing recent errors.
disable-model-invocation: true
allowed-tools: Bash(docker *), Bash(docker-compose *), Bash(ssh *), Read, Glob, Grep
---

# Wetlands Server Health Check

Run diagnostics on the Wetlands Luanti server.

## Checks to Perform

### 1. Local Docker Status
```bash
docker-compose ps
```

### 2. Recent Server Logs
```bash
docker-compose logs --tail=50 luanti-server
```

### 3. Check for Errors
```bash
docker-compose logs luanti-server 2>&1 | grep -i "error\|warning\|fail" | tail -20
```

### 4. Mod Loading Status
```bash
docker-compose logs luanti-server 2>&1 | grep -i "loaded\|registered" | tail -30
```

### 5. Config Validation

Read `server/config/luanti.conf` and verify:
- `creative_mode = true`
- `enable_damage = false`
- `enable_pvp = false`
- All custom mods have `load_mod_*` entries

### 6. World Data Check

Check that world data exists:
- `server/worlds/world/` directory
- `auth.sqlite` present

## Report Format

Provide a summary:
- Server status (running/stopped)
- Active mods count
- Recent errors (if any)
- Config health (ok/issues found)
- Recommendations
