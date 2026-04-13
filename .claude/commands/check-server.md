---
name: check-server
description: Check Wetlands server status, logs, and health on VPS. Diagnoses issues and reports errors.
argument-hint: [wetlands|valdivia|both]
allowed-tools: Bash(ssh *), Bash(docker-compose *), Read, Glob, Grep
---

# Server Health Check

Check the status of the Wetlands server(s) on VPS.

## Target: $ARGUMENTS (default: both)

## Checks

### 1. Container Status
```bash
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && docker-compose ps"
```

### 2. Recent Errors (last 5 minutes)
```bash
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> "docker logs --since='5m' luanti-voxelibre-server 2>&1 | grep -i 'error\|warning\|fail'"
```

### 3. Mod Loading
```bash
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> "docker logs --since='30m' luanti-voxelibre-server 2>&1 | grep -i 'loaded\|registered' | tail -20"
```

### 4. Disk Space
```bash
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> "df -h /home"
```

### 5. Connected Players
```bash
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> "docker logs --since='10m' luanti-voxelibre-server 2>&1 | grep -i 'joins\|leaves'"
```

## Report

Provide a concise summary:
- Server status (running/stopped/error)
- Active errors or warnings
- Disk usage
- Recent player activity
- Recommendations if issues found
