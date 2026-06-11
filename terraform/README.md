# Terraform Local Deployment

This directory contains Terraform configuration for provisioning the EdTech local Docker stack.

## Prerequisites

- Docker installed and running
- Terraform 1.5 or later
- Unix socket access to Docker at `/var/run/docker.sock`

## What this provisions

- Docker network: `edtech-network`
- PostgreSQL container for application data: `edtech_db`
- PostgreSQL container for Airflow metadata: `airflow_db`
- Grafana container: `edtech_grafana`
- Redis container: `airflow_redis`
- Airflow webserver container: `airflow-webserver`
- Airflow scheduler container: `airflow-scheduler`
- Simulator container: `edtech_simulator`

## Usage

1. Initialize Terraform:

```bash
cd terraform
terraform init
```

2. Review the planned resources:

```bash
terraform plan
```

3. Apply the local stack:

```bash
terraform apply
```

4. When finished, destroy the resources:

```bash
terraform destroy
```

## Notes

- The simulator image is built from the repository root using the existing `Dockerfile`.
- The database initialization script `sql/init_edtech.sql` is mounted into the PostgreSQL container.
- Grafana configuration is loaded from `grafana/provisioning` and `grafana/dashboards`.
