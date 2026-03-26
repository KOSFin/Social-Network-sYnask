# Frontend Compose Profiles

Use these Compose files for Dokploy or local environment simulation.

Files:

- `frontend.dev.yml` for Vite dev server in container
- `frontend.prod.yml` for static build served by nginx

## Quick start locally

From `Frontend` directory:

```powershell
Copy-Item .env.dev.example .env.dev
Copy-Item .env.prod.example .env.prod

# Start dev frontend

docker compose -f infra/compose/frontend.dev.yml up --build

# Start prod-like frontend

docker compose -f infra/compose/frontend.prod.yml up --build
```

Notes:

- Dev mode runs Vite on port `5173`.
- Production mode serves static files through nginx on port `80`.
- `VITE_API_BASE_URL` must point to gateway domain for each environment.
- Both files include `quality-gate` service that runs `scripts/deploy-preflight.mjs`.
- Set `API_HEALTHCHECK_URL` in prod to enable backend endpoint smoke checks before startup.
