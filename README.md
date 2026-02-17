# lab-js-notes-microservices

Microservices-based notes app stack with:
- JWT Auth API (`services/lab-js-jwt-auth-api`)
- Notes CRUD API (`services/lab-js-notes-crud-api`)
- React frontend (`services/lab-js-notes-frontend`)
- MongoDB
- Redis (used by Auth API rate limiting when enabled)

Everything is orchestrated with Docker Compose from this repository.

## Repository Structure

```text
.
├── docker-compose.yml
├── docker/
│   ├── auth-api.Dockerfile
│   ├── notes-crud-api.Dockerfile
│   └── notes-frontend.Dockerfile
├── services/
│   ├── lab-js-jwt-auth-api/
│   ├── lab-js-notes-crud-api/
│   └── lab-js-notes-frontend/
└── setup.sh
```

## Services

- `frontend` (Vite + React): exposed on `http://localhost:5173`
- `auth` (Express): exposed on `http://localhost:3000` (base path `/api/v1`)
- `notes` (Express): exposed on `http://localhost:3001` (base path `/api/v1`)
- `mongo` (MongoDB): exposed on `mongodb://localhost:27017`
- `redis` (Redis): exposed on `redis://localhost:6379`

## Prerequisites

- Docker + Docker Compose
- Git

## Quick Start

### Option 1: One-command setup (clone/update service repos + start)

```bash
./setup.sh
```

This script:
1. Clones or updates the three service repositories into `services/`
2. Creates `.env` from `.env.example` if missing
3. Runs `docker compose up --build`

### Option 2: Manual start

```bash
docker compose up --build
```

Stop stack:

```bash
docker compose down
```

Stop and remove Mongo volume:

```bash
docker compose down -v
```

## Environment Configuration

Compose reads environment files from:
- `services/lab-js-jwt-auth-api/.env`
- `services/lab-js-notes-crud-api/.env`
- `services/lab-js-notes-frontend/.env` (used by Vite build/dev runtime)

## API Overview

### Auth API (`http://localhost:3000`)

Base path: `/api/v1`

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`
- `POST /api/v1/auth/verify`
- `GET /api/v1/profile` (requires access token)
- `GET /api/v1/health`

### Notes API (`http://localhost:3001`)

Base path: `/api/v1/notes`

- `POST /api/v1/notes`
- `GET /api/v1/notes`
- `GET /api/v1/notes/:id`
- `PUT /api/v1/notes/:id`
- `DELETE /api/v1/notes/:id`
- `GET /health`

## Common Troubleshooting

### Frontend cannot reach Auth/Notes APIs

Symptoms:
- Network errors in browser for `auth` or `notes` hosts
- CORS errors on requests from `http://localhost:5173`

Checks:
1. Frontend must use `localhost` API URLs in `services/lab-js-notes-frontend/.env`, not Docker DNS names:
   - Correct: `http://localhost:3000/api/v1`, `http://localhost:3001/api/v1`
   - Incorrect (for browser): `http://auth:3000/api/v1`, `http://notes:3001/api/v1`
2. Both APIs must allow browser origin via CORS:
   - `CORS_ORIGIN=http://localhost:5173`
3. Rebuild after env changes:

```bash
docker compose up --build
```

### Port conflicts

If ports `3000`, `3001`, `5173`, `27017`, or `6379` are in use, free them or remap ports in `docker-compose.yml`.

## Development Notes

- Frontend runs Vite dev server with `--host` in container.
- `notes` service talks to `auth` service through Docker network (`http://auth:3000/api/v1`).
- Mongo credentials are set in Compose and consumed via `MONGO_URI` in each API.
- Auth API can use Redis for rate limiting via `RATE_LIMIT_STORE=redis`.
