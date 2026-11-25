COMPOSE := docker compose --env-file .env -f deploy/docker-compose.yml
COMPOSE_DEV := $(COMPOSE) -f deploy/docker-compose.dev.yml
PY_SERVICES := services/gateway services/mock-bank
APP_SERVICES := gateway ledger mock-bank
INFRA_SERVICES := postgres rabbitmq redis

.PHONY: up down logs infra run-gateway run-ledger run-mock-bank \
	test test-ledger test-python lint lint-ledger lint-python

.env:
	cp .env.example .env
	@echo "Created .env from .env.example (development defaults)."

services/gateway/.env:
	cp services/gateway/.env.example services/gateway/.env
	@echo "Created services/gateway/.env from its .env.example."

# --- Full stack in Docker ---

up: .env
	$(COMPOSE) up -d --build --wait

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

# --- Local development: infrastructure in Docker, services run natively ---

# Stops the app containers (they would hold ports 8000/8080) and starts
# Postgres, RabbitMQ and Redis with their ports published on 127.0.0.1.
infra: .env
	-$(COMPOSE) stop $(APP_SERVICES)
	$(COMPOSE_DEV) up -d --wait $(INFRA_SERVICES)

run-gateway: services/gateway/.env
	cd services/gateway && uv run uvicorn app.main:app --reload --port 8000

run-ledger:
	cd services/ledger && dotnet watch --project src/Ledger.Api

run-mock-bank:
	cd services/mock-bank && uv run uvicorn app.main:app --reload --port 8001

# --- Tests and lint ---

test: test-ledger test-python

test-ledger:
	dotnet test services/ledger/Ledger.sln

test-python:
	@for svc in $(PY_SERVICES); do \
		echo "==> pytest $$svc"; \
		(cd $$svc && uv run pytest) || exit 1; \
	done

lint: lint-ledger lint-python

lint-ledger:
	dotnet format services/ledger/Ledger.sln --verify-no-changes

lint-python:
	@for svc in $(PY_SERVICES); do \
		echo "==> lint $$svc"; \
		(cd $$svc && uv run ruff check . && uv run ruff format --check .) || exit 1; \
	done
	cd services/gateway && uv run mypy app tests
