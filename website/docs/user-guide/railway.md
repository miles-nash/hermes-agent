---
sidebar_position: 8
title: "Railway"
description: "Deploy Hermes Agent on Railway with the gateway and web dashboard"
---

# Deploy on Railway

Hermes is best deployed on Railway as one long-running service with a persistent
data volume. The Railway start command runs the messaging gateway in the
background and exposes the web dashboard on Railway's assigned `PORT`.

## What the repo provides

- `railway.toml` tells Railway to build the root `Dockerfile`, run through
  `tini`, and invoke Hermes' Docker entrypoint before the Railway-specific
  start script.
- `docker/railway-start.sh` starts `hermes gateway run` in the background, then
  runs `hermes dashboard --host 0.0.0.0 --port "$PORT"` as the foreground
  process.
- `/opt/data` remains the persistent home for config, API keys, sessions, logs,
  memories, skills, and cron jobs.

## First deploy

1. In Railway, create a new project from the GitHub repository.
2. Add a volume mounted at `/opt/data`. This is where Hermes stores `.env`,
   `config.yaml`, sessions, skills, memories, logs, and cron jobs.
3. Add at least one model-provider key and any platform credentials you want the
   gateway to use. You can also add or edit keys from the dashboard after the
   service starts. For a minimal Telegram setup:

```bash
OPENROUTER_API_KEY=...
TELEGRAM_BOT_TOKEN=...
TELEGRAM_ALLOWED_USERS=123456789
```

4. Deploy the service and generate a Railway domain. The public URL opens the
   dashboard; messaging platforms are served by the background gateway process.

## Optional API server

The default Railway service uses the single public HTTP port for the dashboard.
If you prefer to expose the OpenAI-compatible API server instead, replace the
Railway start command with:

```bash
/usr/bin/tini -g -- /opt/hermes/docker/entrypoint.sh gateway run
```

Then add:

```bash
API_SERVER_KEY=<generate-a-real-secret>
API_SERVER_CORS_ORIGINS=https://your-frontend.example
```

In API-server mode, the Docker entrypoint maps Railway's `PORT` to
`API_SERVER_PORT` and binds the API server to `0.0.0.0`. Use `/health` as the
healthcheck path for that mode.

Do not expose the dashboard publicly unless you put it behind your own
authentication layer. The dashboard can read and write API keys.

## Operational notes

- Keep replicas at one when using the `/opt/data` volume.
- Use Railway variables for secrets; avoid committing `.env`.
- Gateway logs are visible in Railway and persisted under `/opt/data/logs`.
- If you change credentials or platform allowlists, restart or redeploy the
  service so the gateway reloads cleanly.
