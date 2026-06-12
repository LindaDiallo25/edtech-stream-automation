# Docker Deployment

This directory contains Docker Compose and Dockerfile for the EdTech Stream Automation platform.

## Files

- `Dockerfile`: Builds the simulator image from Python 3.9-slim with psycopg2-binary
- `docker-compose.yaml`: Orchestrates all local development services

## Quick Start

From the repository root:

```bash
docker-compose up -d
```

Or from this directory:

```bash
cd docker
docker-compose -f docker-compose.yaml up -d
```

## Services

- PostgreSQL (edtech_db) on port 5432
- Simulator (edtech_simulator)
- Grafana on port 3000
- Airflow PostgreSQL (airflow_db)
- Redis
- Airflow Webserver on port 8080
- Airflow Scheduler

## Stopping

```bash
docker-compose down
```

To remove volumes (⚠️ deletes data):

```bash
docker-compose down -v
```
