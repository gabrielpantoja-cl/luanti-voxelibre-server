# 🔄 VPS Synchronization Workflow

## Overview

This document describes the workflow for keeping the local repository (`luanti-voxelibre-server.git`) in sync with production changes made directly on the VPS.

**Philosophy**: This repository is the **source of truth** for all Luanti server configuration. Any changes made on the VPS should be synchronized back to the local repository to maintain consistency and enable proper version control.

## When to Sync VPS → Local

Synchronize VPS changes to local repository when:

1. **Emergency fixes** were applied directly on VPS
2. **Configuration tuning** was done during production monitoring
3. **Manual backups** or cleanup operations modified configuration
4. **Performance optimizations** were tested and validated on VPS

## Sync Workflow

### Step 1: Identify Changed Files on VPS

```bash
# SSH to VPS
ssh gabriel@167.172.251.27

# Navigate to Luanti directory
cd /home/gabriel/luanti-voxelibre-server

# Check Git status for uncommitted changes
git status

# View changes to specific files
git diff docker-compose.yml
git diff scripts/rotate-backups-container.sh
```

### Step 2: Download Modified Files to Local

From your local machine:

```bash
# Download specific files to temporary location for comparison
scp gabriel@167.172.251.27:/home/gabriel/luanti-voxelibre-server/docker-compose.yml /tmp/docker-compose-vps.yml
scp gabriel@167.172.251.27:/home/gabriel/luanti-voxelibre-server/scripts/rotate-backups-container.sh /tmp/rotate-backups-vps.sh
```

### Step 3: Compare Local vs VPS Files

```bash
# Compare docker-compose.yml
diff -u docker-compose.yml /tmp/docker-compose-vps.yml

# Compare rotate-backups script
diff -u scripts/rotate-backups-container.sh /tmp/rotate-backups-vps.sh
```

### Step 4: Apply Changes to Local Repository

If differences are intentional and should be kept:

```bash
# Copy VPS files over local files
cp /tmp/docker-compose-vps.yml docker-compose.yml
cp /tmp/rotate-backups-vps.sh scripts/rotate-backups-container.sh

# Or use your editor to apply specific changes manually
```

### Step 5: Commit Changes with Descriptive Message

```bash
# Stage modified files
git add docker-compose.yml scripts/rotate-backups-container.sh

# Commit with detailed message
git commit -m "🔧 Sync VPS configuration changes

[Describe what was changed and why]

Changes applied from production VPS after [reason for change].

Affected files:
- docker-compose.yml: [specific changes]
- scripts/rotate-backups-container.sh: [specific changes]

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 6: Push to Remote Repository

```bash
# Push to GitHub
git push origin main
```

### Step 7: Verify VPS is in Sync (Optional)

```bash
# SSH to VPS
ssh gabriel@167.172.251.27

# Pull latest changes from repository
cd /home/gabriel/luanti-voxelibre-server
git pull origin main

# Should show "Already up to date"
```

## Common Sync Scenarios

### Scenario 1: Backup Configuration Optimization

**What happened**: Reduced backup frequency and retention on VPS due to disk usage.

**Files changed**:
- `docker-compose.yml` - Cron schedule modified
- `scripts/rotate-backups-container.sh` - Retention days updated

**Sync process**:
```bash
# Download both files
scp gabriel@167.172.251.27:/home/gabriel/luanti-voxelibre-server/docker-compose.yml /tmp/
scp gabriel@167.172.251.27:/home/gabriel/luanti-voxelibre-server/scripts/rotate-backups-container.sh /tmp/

# Compare and apply changes
diff -u docker-compose.yml /tmp/docker-compose.yml
cp /tmp/docker-compose.yml docker-compose.yml
cp /tmp/rotate-backups-container.sh scripts/rotate-backups-container.sh

# Commit and push
git add docker-compose.yml scripts/rotate-backups-container.sh
git commit -m "🔧 Optimize backup frequency and retention"
git push origin main
```

### Scenario 2: Emergency Server Configuration Fix

**What happened**: Server crashed, configuration was manually fixed on VPS.

**Files changed**:
- `server/config/luanti.conf` - Server settings adjusted

**Sync process**:
```bash
# Download server config
scp gabriel@167.172.251.27:/home/gabriel/luanti-voxelibre-server/server/config/luanti.conf /tmp/

# Compare and apply
diff -u server/config/luanti.conf /tmp/luanti.conf
cp /tmp/luanti.conf server/config/luanti.conf

# Commit and push
git add server/config/luanti.conf
git commit -m "🚨 Emergency fix: Server configuration adjustment"
git push origin main
```

### Scenario 3: Discord Webhook URL Update

**What happened**: Discord webhook was regenerated, `.env` updated on VPS.

**Files changed**:
- `.env` (NOT committed to Git - contains secrets)

**Sync process**:
```bash
# Update .env.example with new format (if structure changed)
# Do NOT commit actual webhook URL

# Document the change
echo "Discord webhook updated on VPS $(date '+%Y-%m-%d')" >> docs/DEPLOYMENT_LOG.md

# Commit documentation update only
git add docs/DEPLOYMENT_LOG.md
git commit -m "📝 Document Discord webhook update"
git push origin main
```

## Monitoring Drift Between Local and VPS

### Automated Drift Detection (Future Enhancement)

Create a script to detect when VPS has uncommitted changes:

```bash
#!/bin/bash
# scripts/check-vps-drift.sh

echo "🔍 Checking for configuration drift..."

ssh gabriel@167.172.251.27 'cd /home/gabriel/luanti-voxelibre-server && git status --porcelain'

if [ $? -eq 0 ]; then
  echo "✅ VPS and local repository are in sync"
else
  echo "⚠️  VPS has uncommitted changes - sync required!"
fi
```

### Manual Drift Check

Periodically run this on VPS:

```bash
ssh gabriel@167.172.251.27 'cd /home/gabriel/luanti-voxelibre-server && git status'
```

If output shows modified files → sync is needed.

## Best Practices

### ✅ DO:
- **Always sync changes back to local repository** within 24 hours
- **Document why changes were made** in commit messages
- **Test changes locally** before applying to VPS when possible
- **Create backups** before major configuration changes
- **Use descriptive commit messages** that explain the "why"

### ❌ DON'T:
- **Don't leave VPS in dirty state** for extended periods
- **Don't commit secrets** (`.env`, passwords, API keys)
- **Don't sync without reviewing changes** first
- **Don't force push** - preserve history
- **Don't modify files directly on VPS** unless absolutely necessary

## Troubleshooting

### Problem: VPS and local have conflicting changes

**Solution**:
```bash
# On VPS, commit changes locally first
ssh gabriel@167.172.251.27
cd /home/gabriel/luanti-voxelibre-server
git add -A
git commit -m "VPS-side changes from $(date '+%Y-%m-%d')"

# Then sync from local
scp gabriel@167.172.251.27:/home/gabriel/luanti-voxelibre-server/docker-compose.yml /tmp/
# Review and merge changes manually
```

### Problem: Accidental changes on VPS

**Solution**:
```bash
# Reset VPS to match remote repository
ssh gabriel@167.172.251.27
cd /home/gabriel/luanti-voxelibre-server
git reset --hard origin/main
docker-compose restart
```

### Problem: Can't remember what was changed on VPS

**Solution**:
```bash
# View detailed diff of all changes
ssh gabriel@167.172.251.27 'cd /home/gabriel/luanti-voxelibre-server && git diff'

# View file-by-file changes
ssh gabriel@167.172.251.27 'cd /home/gabriel/luanti-voxelibre-server && git status -v'
```

## Related Documentation

- `CLAUDE.md` - Project architecture and repository strategy
- `docs/DEPLOYMENT.md` - Deployment workflow
- `docs/VPS_MAINTENANCE.md` - VPS maintenance procedures
- `.github/workflows/deploy.yml` - Automated deployment pipeline

---

**Last Updated**: 2025-11-23
**Maintained By**: Gabriel Pantoja
**Purpose**: Maintain consistency between VPS production environment and local development repository
