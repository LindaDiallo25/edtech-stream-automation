# Prometheus Monitoring

This directory contains Prometheus configuration for the EdTech Stream Automation platform.

## Files

- `prometheus.yml`: Main Prometheus configuration file
- `alerts.yml`: Alerting rules for system health and service availability

## Current configuration

Prometheus is configured to scrape:
- itself (`localhost:9090`)
- Airflow webserver health metrics
- PostgreSQL exporter metrics (if exporter is deployed)
- Node exporter metrics (if exporter is deployed)
- Docker daemon metrics (if exporter is deployed)

> Note: The current `docker-compose.yaml` does not include `postgres_exporter`, `node_exporter`, or `unix_sock_stats_exporter` by default. Add exporter services to your compose setup if you want full database and host-level metrics.

## Access

- Prometheus UI: `http://localhost:9090`
- Grafana UI: `http://localhost:3000`

## Grafana integration

Prometheus is configured as a datasource for Grafana, and dashboards can be loaded from `grafana/dashboards`.

## Extend monitoring

To collect additional metrics, add exporter containers and update `prometheus/prometheus.yml` accordingly. For example:
- `postgres_exporter` for PostgreSQL metrics
- `node_exporter` for system metrics
- `docker_exporter` or similar for Docker metrics
