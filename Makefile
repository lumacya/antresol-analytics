.PHONY: up down psql lint

ifneq (,$(wildcard ./.env))
	include .env
	export
endif

up:
	docker compose -f docker/docker-compose.yml up -d

down:
	docker compose -f docker/docker-compose.yml down

psql:
	docker exec -it postgres sh -c 'psql -U $$POSTGRES_USER -d $$POSTGRES_DB'

lint:
	uv run pre-commit run --all-files
