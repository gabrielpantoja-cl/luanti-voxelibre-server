---
name: deploy
description: Deploy changes to the Wetlands VPS. Runs pre-flight checks, pushes to GitHub, pulls on VPS, and restarts the server.
---

# Deploy to Wetlands VPS

Deploy the current branch to production.

## Target: $ARGUMENTS (default: wetlands)

VPS credentials are in `CLAUDE.local.md` (gitignored). Use `<VPS_USER>` and `<VPS_IP>` as placeholders — never hardcode them in this repo (public on GitHub).

## Step 1: Pre-flight Checks

1. Run `git status` — abort if there are uncommitted changes.
2. Read `server/config/luanti-original.conf` and verify it matches the **documented** state in `CLAUDE.md`:
   - `creative_mode = true`
   - `enable_damage = true` (intentional — hostile mobs at night + PvP arena)
   - `enable_pvp = false` (non-arena PvP blocked by `pvp_arena` mod)
   - `enable_tnt = false`
   - `only_peaceful_mobs = false`
3. For each new mod in `server/mods/`, verify `mod.conf` and `init.lua` exist.
4. Check `docker-compose.yml` volume mappings haven't changed vs last commit (volume reshuffles corrupt textures).
5. Flag any changes to `.env`, `auth.sqlite`, or `server/worlds/` — those should never be committed.

If any check fails, report and **stop**. Do not deploy.

## Step 2: Push to GitHub

```bash
git push origin main
```

## Step 3: Pull on VPS

```bash
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && git pull origin main"
```

### If `git pull` fails with "Permission denied"

The container (running as UID 1000 per `PUID` in compose) wrote to mounted volumes. Scope the `chown` fix to directories git needs — **never** touch `server/worlds/` or `server/config/`:

```bash
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && \
  sudo chown -R <VPS_USER>:<VPS_USER> server/mods server/games server/landing-page \
       server/skins scripts docs *.md *.yml *.conf 2>/dev/null || true"
```

### If `git pull` fails with "Your local changes would be overwritten"

Inspect first — don't force:

```bash
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && git diff <file>"
```

If the local change is identical to incoming (common with manual hotfixes), `git stash` the file, pull, then drop or pop:

```bash
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && \
  git stash push -m 'pre-deploy-$(date +%s)' -- <file> && git pull origin main"
```

## Step 4 (only for new-mod deploys): world.mt entry

**CRITICAL**: a new mod must be listed as `= true` in `world.mt` to register. Adding it to `luanti-original.conf` alone is insufficient (verified 2026-04-19 with `mypark`).

```bash
ssh <VPS_USER>@<VPS_IP> "grep <mod> /home/<VPS_USER>/luanti-voxelibre-server/server/worlds/world/world.mt || \
  echo 'load_mod_<mod> = true' | sudo tee -a /home/<VPS_USER>/luanti-voxelibre-server/server/worlds/world/world.mt"
```

## Step 5: Restart Server

For wetlands:
```bash
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && docker compose restart luanti-server"
```

For valdivia:
```bash
ssh <VPS_USER>@<VPS_IP> "cd /home/<VPS_USER>/luanti-voxelibre-server && docker compose restart luanti-valdivia"
```

## Step 6: Verify

Wait ~20s, then:

```bash
ssh <VPS_USER>@<VPS_IP> "docker ps --filter name=luanti-voxelibre-server --format '{{.Status}}'"
ssh <VPS_USER>@<VPS_IP> "docker logs --since='2m' luanti-voxelibre-server 2>&1 | grep -iE 'error|warning|fatal'"
```

Expect `Up N seconds (healthy)` and no fatal errors. Pre-existing warnings (missing `server_rules`, `mcl_back_to_spawn`; `mcl_weather` shutdown noise) are known and non-blocking — flag them only if new.

### If fatal "Couldn't save env meta"

You probably chowned `server/worlds/` by mistake. Restore container ownership:

```bash
ssh <VPS_USER>@<VPS_IP> "sudo chown -R 1000:1000 \
  /home/<VPS_USER>/luanti-voxelibre-server/server/worlds \
  /home/<VPS_USER>/luanti-voxelibre-server/server/config && \
  cd /home/<VPS_USER>/luanti-voxelibre-server && docker compose restart luanti-server"
```

## Step 7: Report

**DEPLOY OK** or **DEPLOY FAILED** with specific errors, not a generic "something went wrong".
