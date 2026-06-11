# EdTech Stream Automation

A containerized data simulation and analytics platform for educational streaming activity. This repository includes a PostgreSQL-backed simulator, Grafana monitoring, and an Airflow analytics DAG.

## 🚀 What this project includes

- **Python simulator** that creates student records and writes data into PostgreSQL
- **PostgreSQL database** with `students`, `lessons`, and `streaming_logs` tables
- **Grafana monitoring** configuration under `grafana/`
- **Apache Airflow workflow** in `dags/edtech_dag.py` for daily analytics
- **Docker Compose** environment for local development and testing
- **Kubernetes deployment** manifest in `k8s-deployment.yaml`

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
├── docker-compose.yaml
├── k8s-deployment.yaml
├── dags/
│   └── edtech_dag.py
├── grafana/
│   ├── dashboards/
│   └── provisioning/
├── logs/
├── scripts/
│   └── edtech_simulator.py
└── sql/
    └── init_edtech.sql
```

## 📋 Prerequisites

- Docker
- Docker Compose
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

- `db`: PostgreSQL database for the EdTech dataset
- `simulator`: Python simulator that inserts student records into PostgreSQL
- `grafana`: Grafana dashboard service
- `airflow_db`: PostgreSQL metadata database for Airflow
- `redis`: Redis instance used by Airflow if needed
- `airflow-webserver`: Airflow web UI on port `8080`
- `airflow-scheduler`: Airflow scheduler running DAG tasks

## 🔌 Access endpoints

- Grafana: `http://localhost:3000`
  - Admin password: `admin`
- Airflow Webserver: `http://localhost:8080`
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
- Airflow metadata database
- Redis
- Airflow webserver and scheduler

### `scripts/edtech_simulator.py`

The simulator script:
- connects to PostgreSQL
- inserts random student records every 5 seconds
- uses hardcoded student names and classroom values

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

## 🧪 Notes

- `docker-compose.yaml` currently also mounts `./plugins` for Airflow, which is expected to be created by Docker if missing.
- The simulator inserts students directly into `students`; the `streaming_logs` table is currently defined but populated only by future workflow enhancements.

## 🤝 Contributing

Contributions are welcome. Open a pull request with improvements, bug fixes, or documentation updates.

## 📜 License

This repository does not include a license file in the current tree.

