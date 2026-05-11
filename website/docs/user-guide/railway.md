---
sidebar_position: 8
title: "Railway"
description: "Deploy Hermes Agent as a Railway gateway worker"
---

# Deploy on Railway

Hermes is best deployed on Railway as a long-running gateway worker: one service,
one persistent data volume, and no public HTTP surface unless you deliberately
enable the API server.

## What the repo provides

- `railway.toml` tells Railway to build the root `Dockerfile` and start the
  gateway with `/opt/hermes/docker/entrypoint.sh gateway run`.
- The Docker entrypoint maps Railway's injected `PORT` to `API_SERVER_PORT` on
  Railway, but only when `API_SERVER_KEY` is set or `API_SERVER_ENABLED=true`.
  This keeps private worker deploys from accidentally exposing an HTTP service.

## First deploy

1. In Railway, create a new project from the GitHub repository.
2. Add a volume mounted at `/opt/data`. This is where Hermes stores `.env`,
   `config.yaml`, sessions, skills, memories, logs, and cron jobs.
3. Add at least one model-provider key and the platform credentials you want
   the gateway to use. For a minimal Telegram setup:

```bash
OPENROUTER_API_KEY=...
TELEGRAM_BOT_TOKEN=...
TELEGRAM_ALLOWED_USERS=123456789
```

4. Deploy the service. The checked-in Railway config starts `hermes gateway run`
   in the foreground so Railway can supervise and restart it.

## Optional API server

To expose the OpenAI-compatible API server, add:

```bash
API_SERVER_KEY=<generate-a-real-secret>
API_SERVER_CORS_ORIGINS=https://your-frontend.example
```

Then generate a Railway domain for the service. On Railway, the entrypoint will
bind the API server to `0.0.0.0:$PORT` automatically. If you enable a healthcheck
for this mode, use `/health`.

Do not expose the dashboard publicly unless you put it behind your own
authentication layer. The dashboard can read and write API keys.

## Operational notes

- Keep replicas at one when using the `/opt/data` volume.
- Use Railway variables for secrets; avoid committing `.env`.
- Gateway logs are visible in Railway and persisted under `/opt/data/logs`.
- If you change credentials or platform allowlists, restart or redeploy the
  service so the gateway reloads cleanly.
