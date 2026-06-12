# EdTech Stream Automation

A containerized data simulation and analytics platform for educational streaming activity. This repository includes a PostgreSQL-backed simulator, Grafana monitoring, Prometheus alerting, Airflow analytics, and infrastructure provisioning.

## 🚀 What this project includes

- **Python simulator** that generates student streaming events and writes them to PostgreSQL
- **PostgreSQL database** with `students`, `lessons`, and `streaming_logs` tables
- **Grafana monitoring** configuration under `grafana/`
- **Prometheus** metric collection and alerting under `prometheus/`
- **Apache Airflow** workflow in `dags/edtech_dag.py` for analytics and reporting
- **Docker Compose** environment for local development and testing
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
- Terraform 1.5+ (local execution)
- AWS CLI + credentials if using the Terraform AWS path
- (Optional) Kubernetes and `kubectl`

## 🛠️ Local setup with Docker Compose

1. Clone the repository:

```bash
git clone https://github.com/LindaDiallo25/edtech-stream-automation.git
cd edtech-stream-automation
```

2. Start all services:

```bash
docker-compose up -d
```

3. Verify services:

```bash
docker-compose ps
```

## 🌐 Services started by Docker Compose

- `db`: PostgreSQL database for application data
- `simulator`: Python simulator generating streaming events
- `grafana`: Grafana dashboard service
- `airflow_db`: PostgreSQL metadata database for Airflow
- `redis`: Redis service used by Airflow
- `airflow-webserver`: Airflow web UI on port `8080`
- `airflow-scheduler`: Airflow scheduler running DAG tasks
- `prometheus`: Prometheus monitoring service on port `9090`

## 🔌 Access endpoints

- Grafana: `http://localhost:3000`
  - Admin password: `admin`
- Airflow Webserver: `http://localhost:8080`
- Prometheus: `http://localhost:9090`
- PostgreSQL: `localhost:5432`
  - Database: `edtech_db`
  - User: `admin`
  - Password: `password`

## 📦 Key components

### `Dockerfile`

Builds the simulator image using Python 3.9 and installs `psycopg2-binary`.

### `docker-compose.yaml`

Defines the full local stack:
- PostgreSQL database for application data
- Python simulator container
- Grafana dashboard
- Prometheus monitoring
- Airflow metadata database
- Redis
- Airflow webserver and scheduler

### `scripts/edtech_simulator.py`

The simulator script:
- connects to PostgreSQL
- inserts student and streaming event records every 5 seconds
- generates realistic watch time and completion percentages

### `dags/edtech_dag.py`

Daily Airflow DAG that:
- analyzes student engagement
- analyzes lesson completion
- analyzes classroom performance
- generates a daily report

### `sql/init_edtech.sql`

Initial schema and seed data for:
- `students`
- `lessons`
- `streaming_logs`

## 📊 Database schema

The SQL initialization script creates:
- `students` with `student_id`, `name`, and `classroom`
- `lessons` with `lesson_id`, `title`, and `subject`
- `streaming_logs` with references to `students` and `lessons`, plus watch time and completion percentage

## 🧱 Terraform deployment

Terraform can provision the AWS EC2-based stack from the `terraform/` directory.

1. Initialize Terraform:

```bash
cd terraform
terraform init
```

2. Review the plan:

```bash
terraform plan
```

3. Apply the stack:

```bash
terraform apply
```

4. Destroy the stack when finished:

```bash
terraform destroy
```

> Note: The AWS Terraform path deploys a single Ubuntu EC2 instance, bootstraps Docker and Docker Compose, and deploys the full stack automatically.

## ☸️ Kubernetes deployment

Apply the manifest with:

```bash
kubectl apply -f k8s-deployment.yaml
```

This file includes deployments and services for the simulator, Grafana, Airflow database, scheduler, and webserver.

## 🔧 Configuration

Environment variables used by the simulator service in Docker Compose:

- `DB_HOST=db`
- `DB_NAME=edtech_db`
- `DB_USER=admin`
- `DB_PASS=password`

## 🔄 Running and validating

Check simulator logs:

```bash
docker logs edtech_simulator
```

Query the database:

```bash
docker exec -it edtech_db psql -U admin -d edtech_db -c "SELECT COUNT(*) FROM students;"
```

Verify Prometheus targets:

```bash
curl http://localhost:9090/api/v1/targets
```

Verify Grafana datasource:

```bash
curl -u admin:admin http://localhost:3000/api/datasources
```

## 🧪 Deployment verification

1. Confirm services are running:

```bash
docker-compose ps
```

2. Confirm metric scraping:

```bash
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, state: .health}'
```

3. Confirm dashboard access:

- Grafana: `http://localhost:3000`
- Prometheus: `http://localhost:9090`
- Airflow: `http://localhost:8080`

4. Confirm data ingestion:

```bash
docker exec -it edtech_db psql -U admin -d edtech_db -c "SELECT COUNT(*) FROM streaming_logs;"
```

## ⚠️ Notes

- The `docker-compose.yaml` file mounts `./plugins` for Airflow and creates it if needed.
- The simulator now generates both student records and streaming event data into `streaming_logs`.
- Prometheus is configured with alert rules under `prometheus/alerts.yml`.
- For production, restrict security access and avoid public exposure of service ports.

## 🤝 Contributing

Contributions are welcome via issues and pull requests. Please open an issue first if you want to add new deployment paths, dashboards, or analytic workflows.

Contributions are welcome. Open a pull request with improvements, bug fixes, or documentation updates.

## 📜 License

This repository does not include a license file in the current tree.

