# Hermes Agent — Render Deployment Guide

## Overview

This deploys [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) as an
OpenAI-compatible API server on Render, backed by **OpenRouter** for model access and a
**persistent disk** so memories/sessions survive restarts.

---

## Step 1 — Fork the Repository

1. Go to https://github.com/NousResearch/hermes-agent
2. Click **Fork** (top-right) → choose your GitHub account
3. Clone your fork locally:

```bash
git clone https://github.com/YOUR-USERNAME/hermes-agent.git
cd hermes-agent
```

---

## Step 2 — Add the Deployment Files

Copy both files from this folder into the **root** of your cloned fork:

```
hermes-agent/
├── Dockerfile        ← add this
├── render.yaml       ← add this
└── ... (existing repo files)
```

Then push them:

```bash
git add Dockerfile render.yaml
git commit -m "Add Render deployment config"
git push
```

---

## Step 3 — Create the Render Service

1. Go to https://render.com and sign in (or sign up — free account is fine)
2. Click **New +** → **Web Service**
3. Click **Connect a repository** → select your forked `hermes-agent` repo
4. Render will auto-detect `render.yaml` and pre-fill most settings
5. Click **Create Web Service**

---

## Step 4 — Add Your OpenRouter API Key

1. Get your key from https://openrouter.ai/keys (free to sign up)
2. In your Render service dashboard → **Environment** tab
3. Add:

| Key | Value |
|-----|-------|
| `OPENROUTER_API_KEY` | `sk-or-xxxxxxxxxx` |

4. Click **Save Changes** — Render will automatically redeploy

---

## Step 5 — Configure the Model (after first deploy)

Open the Render **Shell** tab in your service dashboard and run:

```bash
hermes model
```

Select **OpenRouter**, then choose a model. Recommended choices:

- `anthropic/claude-sonnet-4` — best reasoning, 200K context
- `deepseek/deepseek-chat` — very cheap, strong coding
- `qwen/qwen3-235b-a22b` — massive open-weight model
- `google/gemini-2.5-pro` — 1M context

Hermes works best with **64K+ context** models.

---

## Step 6 — Verify the Deployment

Replace `YOUR-RENDER-URL` with the URL shown in your Render dashboard:

```bash
# Health check
curl https://YOUR-RENDER-URL.onrender.com/health

# List models
curl https://YOUR-RENDER-URL.onrender.com/v1/models

# Test chat completion
curl https://YOUR-RENDER-URL.onrender.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "hermes-agent",
    "messages": [{"role": "user", "content": "Hello, are you running?"}]
  }'
```

---

## Important Notes

### Render Plan
Use at least **Starter ($7/mo)**. The free tier:
- Sleeps after 15 min of inactivity
- Has no persistent disk support
- Will lose all Hermes memory on restart

### Persistent Disk
The `render.yaml` attaches a 10 GB disk at `/data`. Hermes stores everything there:
- Conversation memory
- Skills and tools
- Session history
- Model config

### Browser Automation
Some Hermes features (Playwright/Chromium) may be limited on Render's sandboxed
containers. Core agent and API features work fine.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Deploy fails at `uv pip install` | Check build logs — a system dep may be missing in Dockerfile |
| `hermes gateway` command not found | Hermes didn't install correctly — check `uv pip install -e .` output |
| API returns 401/403 | `OPENROUTER_API_KEY` not set or invalid |
| Memory lost after restart | Persistent disk not mounted — verify `render.yaml` disk config |
| Service sleeps | Upgrade from free to Starter plan |
