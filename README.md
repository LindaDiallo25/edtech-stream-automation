# EdTech Stream Automation

A containerized data simulation and analytics platform for educational streaming activity. This repository includes a PostgreSQL-backed simulator, Grafana monitoring, Prometheus alerting, Airflow analytics, and optional infrastructure provisioning.

## 🚀 What this project includes

- **Python simulator** that generates student streaming events and writes them to PostgreSQL
- **PostgreSQL database** with `students`, `lessons`, and `streaming_logs` tables
- **Grafana monitoring** configuration under `grafana/`
- **Prometheus** metric collection and alerting under `prometheus/`
- **Apache Airflow** workflow in `dags/edtech_dag.py` for analytics and reporting
- **Docker Compose** local development stack
- **Terraform AWS** deployment example in `terraform/`
- **Kubernetes** deployment manifest in `k8s-deployment.yaml`

## 📁 Repository structure

```
edtech-stream-automation/
├── ARCHITECTURE.md
├── ARCHITECTURE_DIAGRAM.md
├── BENCHMARKS.md
├── DATA_MODEL.md
├── Dockerfile
├── README.md
├── db-service.yaml
├── docker/
│   ├── Dockerfile
│   ├── README.md
│   └── docker-compose.yaml
├── docker-compose.yaml
├── dags/
│   └── edtech_dag.py
├── grafana/
│   ├── dashboards/
│   └── provisioning/
├── k8s-deployment.yaml
├── logs/
├── prometheus/
│   ├── alerts.yml
│   ├── prometheus.yml
│   └── README.md
├── scripts/
│   └── edtech_simulator.py
├── sql/
│   └── init_edtech.sql
└── terraform/
    ├── main.tf
    ├── providers.tf
    ├── variables.tf
    ├── versions.tf
    ├── outputs.tf
    ├── user_data.sh
    └── README.md
```

## 📋 Prerequisites

- Docker
- Docker Compose
- Terraform 1.5+ (if using Terraform)
- AWS CLI + credentials (if using the Terraform AWS path)
- (Optional) Kubernetes and `kubectl`

## 🛠 Local development with Docker Compose

### Start the stack

From the repository root:

```bash
docker-compose up -d
```

### Verify services

```bash
docker-compose ps
```

### Services started by Docker Compose

- `db`: PostgreSQL database for application data
- `simulator`: Python simulator generating streaming events
- `grafana`: Grafana dashboard service
- `prometheus`: Prometheus monitoring service
- `airflow_db`: PostgreSQL metadata database for Airflow
- `redis`: Redis service for Airflow
- `airflow-webserver`: Airflow web UI on port `8080`
- `airflow-scheduler`: Airflow scheduler running DAG tasks

### Access endpoints

- Grafana: `http://localhost:3000`
  - Admin password: `admin`
- Airflow Webserver: `http://localhost:8080`
- Prometheus: `http://localhost:9090`
- PostgreSQL: `localhost:5432`
  - Database: `edtech_db`
  - User: `admin`
  - Password: `password`

## 🔧 Project documentation

- Architecture requirements: `ARCHITECTURE.md`
- Architecture diagrams: `ARCHITECTURE_DIAGRAM.md`
- Performance and scalability: `BENCHMARKS.md`
- Data model and schema: `DATA_MODEL.md`
- Docker-specific docs: `docker/README.md`
- Prometheus docs: `prometheus/README.md`
- Terraform deployment docs: `terraform/README.md`

## 📦 Key components

### `Dockerfile`

Builds the simulator image from Python 3.9 and installs dependencies such as `psycopg2-binary`.

### `docker-compose.yaml`

Defines the local stack:
- PostgreSQL application database
- Python simulator container
- Grafana dashboard
- Prometheus monitoring
- Airflow metadata database
- Redis
- Airflow webserver and scheduler

### `scripts/edtech_simulator.py`

Simulator script that:
- connects to PostgreSQL
- inserts student and streaming event records every 5 seconds
- generates watch time and completion percentages

### `dags/edtech_dag.py`

Airflow DAG that:
- analyzes student engagement
- analyzes lesson completion
- analyzes classroom performance
- generates a daily report

### `sql/init_edtech.sql`

Initial schema and seed data for:
- `students`
- `lessons`
- `streaming_logs`

## ☸️ Kubernetes deployment

Apply the manifest:

```bash
kubectl apply -f k8s-deployment.yaml
```

This is an example on-premise Kubernetes deployment and may require adaptation for your cluster.

## 🌐 Terraform AWS deployment

See `terraform/README.md` for instructions to provision an AWS EC2 instance that bootstraps Docker and deploys the stack.

## ✅ Validation commands

Check service status:

```bash
docker-compose ps
```

Confirm data ingestion:

```bash
docker exec -it edtech_db psql -U admin -d edtech_db -c "SELECT COUNT(*) FROM streaming_logs;"
```

Confirm Prometheus targets:

```bash
curl http://localhost:9090/api/v1/targets
```

Confirm Grafana datasources:

```bash
curl -u admin:admin http://localhost:3000/api/datasources
```

## ⚠️ Notes

- `docker-compose.yaml` mounts `./dags`, `./logs`, and `./plugins` for Airflow.
- Prometheus is configured under `prometheus/` and can be extended with additional exporters.
- `grafana/provisioning` and `grafana/dashboards` contain Grafana provisioning and dashboard configuration.
