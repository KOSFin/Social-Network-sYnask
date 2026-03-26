# Synask Frontend

Frontend for Synask built with React + Vite.

## Local run

```powershell
npm install
npm run dev
```

## Quality checks

```powershell
npm run lint
npm run test:run
npm run build
```

Unified preflight script:

```powershell
npm run deploy:preflight
```

## Docker profiles

The repository contains two Docker profiles:

- `docker/Dockerfile.dev` for containerized Vite dev server
- `docker/Dockerfile.prod` for production static build with nginx

Compose files:

- `infra/compose/frontend.dev.yml`
- `infra/compose/frontend.prod.yml`

Environment templates:

- `.env.dev.example`
- `.env.prod.example`

## Dokploy

Create two Dokploy applications for frontend:

- dev -> compose file `Frontend/infra/compose/frontend.dev.yml`
- production -> compose file `Frontend/infra/compose/frontend.prod.yml`

Set `VITE_API_BASE_URL` per environment to the corresponding backend gateway domain.
Optionally set `API_HEALTHCHECK_URL` to run backend endpoint smoke checks during preflight.

## Git flow and releases

Branch model:

- `main`: production branch
- `develop`: integration/testing branch
- `feature/*`: feature development branches
- `release/*`: release preparation branches
- `hotfix/*`: urgent production fixes

Automation script:

- `scripts/gitflow.ps1`

Examples:

```powershell
# If repository has no commits yet
./scripts/bootstrap-first-commit.ps1 -Push

# One-time init (after first commit)
./scripts/gitflow.ps1 -Action init -Push

# Start feature branch
./scripts/gitflow.ps1 -Action feature-start -Name ui-profile -Push

# Finish feature branch (merge into develop)
./scripts/gitflow.ps1 -Action feature-finish -Name ui-profile -Push

# Start release branch
./scripts/gitflow.ps1 -Action release-start -Version 1.2.0 -Push

# Finish release (merge into main + tag + back-merge into develop)
./scripts/gitflow.ps1 -Action release-finish -Version 1.2.0 -Push
```

Frontend release workflow:

- File: `.github/workflows/frontend-release.yml`
- Trigger: push to `main`
- Creates tag and GitHub Release when commit message contains one of:
	- `release: v1.2.3`
	- `version: 1.2.3`
	- `[release v1.2.3]`
