# lab-js-notes-microservices

Microservices-based notes app stack with:
- JWT Auth API (`services/lab-js-jwt-auth-api`)
- Notes CRUD API (`services/lab-js-notes-crud-api`)
- React frontend (`services/lab-js-notes-frontend`)
- MongoDB

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
- `auth` (Express): exposed on `http://localhost:3000`
- `notes` (Express): exposed on `http://localhost:3001`
- `mongo` (MongoDB): exposed on `mongodb://localhost:27017`

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

### Recommended local values (browser on localhost)

Frontend `.env`:

```env
VITE_AUTH_API_URL=http://localhost:3000
VITE_NOTES_API_URL=http://localhost:3001/api
```

Auth API `.env`:

```env
PORT=3000
CORS_ORIGIN=http://localhost:5173
MONGO_URI=mongodb://root:example@mongo:27017/auth_db?authSource=admin
JWT_SECRET=<your-secret>
JWT_REFRESH_SECRET=<your-refresh-secret>
LOG_LEVEL=info
```

Notes API `.env`:

```env
PORT=3001
CORS_ORIGIN=http://localhost:5173
MONGO_URI=mongodb://root:example@mongo:27017/notes_db?authSource=admin
AUTH_SERVICE_URL=http://auth:3000
LOG_LEVEL=info
```

## API Overview

### Auth API (`http://localhost:3000`)

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `POST /auth/verify`
- `GET /profile` (requires access token)
- `GET /health`

### Notes API (`http://localhost:3001`)

Base path: `/api/notes`

- `POST /api/notes`
- `GET /api/notes`
- `GET /api/notes/:id`
- `PUT /api/notes/:id`
- `DELETE /api/notes/:id`
- `GET /health`

## Common Troubleshooting

### Frontend cannot reach Auth/Notes APIs

Symptoms:
- Network errors in browser for `auth` or `notes` hosts
- CORS errors on requests from `http://localhost:5173`

Checks:
1. Frontend must use `localhost` API URLs in `services/lab-js-notes-frontend/.env`, not Docker DNS names:
   - Correct: `http://localhost:3000`, `http://localhost:3001/api`
   - Incorrect (for browser): `http://auth:3000`, `http://notes:3001/api`
2. Both APIs must allow browser origin via CORS:
   - `CORS_ORIGIN=http://localhost:5173`
3. Rebuild after env changes:

```bash
docker compose up --build
```

### Port conflicts

If ports `3000`, `3001`, `5173`, or `27017` are in use, free them or remap ports in `docker-compose.yml`.

## Development Notes

- Frontend runs Vite dev server with `--host` in container.
- `notes` service talks to `auth` service through Docker network (`http://auth:3000`).
- Mongo credentials are set in Compose and consumed via `MONGO_URI` in each API.

