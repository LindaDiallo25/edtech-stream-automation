# Docker Deployment

This directory contains Docker Compose and Dockerfile support for the EdTech Stream Automation platform.

## What is included

- `Dockerfile`: Builds the simulator image from Python 3.9-slim with `psycopg2-binary`
- `docker-compose.yaml`: Orchestrates the local development stack

## Quick start

From the repository root:

```bash
docker-compose up -d
```

Or from this directory:

```bash
cd docker
docker-compose -f docker-compose.yaml up -d
```

## Services included

- PostgreSQL (`edtech_db`) on port `5432`
- Simulator (`edtech_simulator`)
- Grafana on port `3000`
- Prometheus on port `9090`
- Airflow metadata PostgreSQL (`airflow_db`)
- Redis
- Airflow webserver on port `8080`
- Airflow scheduler

## Stop and remove services

```bash
docker-compose down
```

To remove volumes (data will be deleted):

```bash
docker-compose down -v
```
