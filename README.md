# payments-ledger

A portfolio payments system built as a small set of services: a public
FastAPI gateway accepts payment requests, a .NET double-entry ledger records
them in PostgreSQL with idempotency keys and publishes events to RabbitMQ
through an outbox, and a mock bank simulates the unreliable outside world
(timeouts, partial failures, duplicate callbacks). **Status: scaffolding only;
every service currently exposes just a health check.**

## Services

| Service | Stack | Purpose | Exposed to host |
|---|---|---|---|
| `gateway` | Python 3.12, FastAPI | Public REST API (JWT/OAuth2), reconciliation job, event consumer | yes, `:8000` |
| `ledger` | C# / .NET 8, minimal APIs | Double-entry ledger, idempotency, outbox to RabbitMQ | no |
| `mock-bank` | Python 3.12, FastAPI | Fake bank with injected failures | no |
| `postgres` | PostgreSQL 16 | Databases `ledger` and `gateway` | no |
| `rabbitmq` | RabbitMQ 3.13 + management | Event bus | management UI only, `:15672` |
| `redis` | Redis 7 | Idempotency cache | no |

## Repository layout

```
services/ledger      .NET 8 solution (Ledger.Api + Ledger.Tests)
services/gateway     FastAPI app + tests
services/mock-bank   FastAPI app + tests
contracts/           event schemas (empty for now)
deploy/              docker-compose.yml, Postgres init script
docs/                architecture notes and decisions
```

## Running

Requirements: Docker with Compose v2, .NET 8 SDK, [uv](https://docs.astral.sh/uv/).

```bash
make up      # creates .env from .env.example if missing, builds, waits until all containers are healthy
curl localhost:8000/health
make test    # dotnet test + pytest for both Python services
make lint    # dotnet format, ruff, mypy
make logs
make down
```

All secrets and connection strings live in `.env` (git-ignored). `.env.example`
holds development defaults only.

### Local development (services run natively, with hot reload)

Infrastructure runs in Docker; the services you are editing run on your machine
and restart on every save.

```bash
make infra          # Postgres, RabbitMQ, Redis in Docker, ports published on 127.0.0.1
make run-gateway    # http://localhost:8000  (uvicorn --reload)
make run-ledger     # http://localhost:8080  (dotnet watch)
make run-mock-bank  # http://localhost:8001  (uvicorn --reload)
make down           # stop everything
```

Run each `run-*` target in its own terminal. Local settings come from
`services/gateway/.env` (created from its `.env.example`) and
`services/ledger/src/Ledger.Api/appsettings.Development.json`, both pointing at
`localhost`. `make infra` stops the app containers so their ports are free.
Before pushing, run `make up` and `make test` to check the real images.

## Architecture

> **TODO**: service interactions, payment flow, outbox and idempotency design.

## Failure Handling

> **TODO**: timeouts, retries, duplicate callbacks, reconciliation.

## Demo

> **TODO**: end-to-end walkthrough.
