# Prometheus Monitoring

Prometheus is a time-series monitoring system that collects metrics from services and provides alerting capabilities.

## Configuration

- **prometheus.yml**: Main Prometheus configuration file with scrape configs for:
  - Prometheus self-monitoring
  - PostgreSQL metrics (via postgres_exporter)
  - Node metrics (via node_exporter)
  - Airflow webserver health
  - Docker daemon metrics

- **alerts.yml**: Alert rules for:
  - PostgreSQL service health
  - Connection and query count thresholds
  - Airflow webserver availability
  - DAG failures
  - System resource usage (CPU, memory, disk)

## Access

- **Prometheus UI**: `http://localhost:9090`
- **Grafana with Prometheus datasource**: `http://localhost:3000`
  - Included dashboard: "EdTech Prometheus Monitoring"

## Exporters

To enable full metric collection, you can add these exporters:

- **postgres_exporter**: Collects PostgreSQL metrics
- **node_exporter**: Collects system metrics (CPU, memory, disk, network)
- **docker-compose-exporter**: Collects Docker container metrics

Add them to your docker-compose.yaml to expand monitoring capabilities.

## Grafana Integration

Prometheus is configured as a datasource in Grafana and includes a monitoring dashboard for:
- Service status tracking
- System CPU and memory usage
- Prometheus health status
