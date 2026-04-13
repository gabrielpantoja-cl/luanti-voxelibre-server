---
name: deploy
description: Deploy changes to the Wetlands VPS. Runs pre-flight checks, pushes to GitHub, pulls on VPS, and restarts the server.
argument-hint: [wetlands|valdivia|both]
allowed-tools: Read, Glob, Grep, Bash(git *), Bash(ssh *), Bash(docker-compose *)
---

# Deploy to Wetlands VPS

Deploy the current branch to production.

## Target: $ARGUMENTS (default: wetlands)

## Step 1: Pre-flight Checks

1. Run `git status` — abort if there are uncommitted changes
2. Read `server/config/luanti.conf` and verify critical settings:
   - `creative_mode = true`
   - `enable_damage = false`
   - `enable_pvp = false`
   - `enable_tnt = false`
3. For each mod in `server/mods/`, verify `mod.conf` and `init.lua` exist
4. Check `docker-compose.yml` volume mappings haven't changed vs last commit
5. Flag any changes to `.env`, `auth.sqlite`, or `server/worlds/`

If any check fails, report and **stop**. Do not deploy.

## Step 2: Push to GitHub

```bash
git push origin main
```

## Step 3: Pull on VPS

```bash
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && git pull origin main"
```

## Step 4: Restart Server

For wetlands:
```bash
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && docker-compose restart luanti-server"
```

For valdivia:
```bash
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && docker-compose restart luanti-valdivia"
```

## Step 5: Verify

```bash
ssh -i ~/.ssh/id_ed25519 <VPS_USER>@<VPS_IP> "docker logs --since='2m' luanti-voxelibre-server 2>&1 | grep -i 'error\|warning'"
```

Report: **DEPLOY OK** or **DEPLOY FAILED** with details.
