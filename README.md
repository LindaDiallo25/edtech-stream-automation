# EdTech Stream Automation

A comprehensive automation system for simulating and monitoring student streaming data in an educational technology platform. This project demonstrates containerized data streaming, database management, and analytics workflows using Docker, Kubernetes, PostgreSQL, and Apache Airflow.

## 🚀 Features

- **Real-time Data Simulation**: Python-based simulator that generates student streaming data continuously
- **PostgreSQL Database**: Robust data storage for students, lessons, and streaming logs
- **Grafana Monitoring**: Visual dashboards for monitoring teacher and student analytics
- **Airflow Integration**: Automated daily analytics workflows for engagement metrics
- **Containerized Architecture**: Docker Compose setup for easy local development
- **Kubernetes Support**: Production-ready deployment configuration

## 📋 Prerequisites

- [Docker](https://www.docker.com/get-started) (version 20.10 or higher)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0 or higher)
- [Kubernetes](https://kubernetes.io/docs/setup/) (optional, for production deployment)

## 🏗️ Architecture

The system consists of three main services:

1. **PostgreSQL Database** (`db`): Stores student data, lessons, and streaming logs
2. **EdTech Simulator** (`simulator`): Python service that continuously generates and inserts student data
3. **Grafana** (`grafana`): Monitoring and visualization dashboard (accessible on port 3000)

## 🛠️ Installation & Setup

### Using Docker Compose (Recommended)

1. Clone the repository:
```bash
git clone https://github.com/yourusername/edtech-stream-automation.git
cd edtech-stream-automation
```

2. Start all services:
```bash
docker-compose up -d
```

3. Verify services are running:
```bash
docker-compose ps
```

### Access Services

- **Grafana Dashboard**: http://localhost:3000
  - Username: `admin`
  - Password: `admin`
- **PostgreSQL Database**: 
  - Host: `localhost` (from host machine)
  - Port: `5432` (if exposed)
  - Database: `edtech_db`
  - User: `admin`
  - Password: `password`

## 📊 Database Schema

The system uses the following tables:

- **students**: Stores student information (name, classroom)
- **lessons**: Contains lesson metadata (title, subject)
- **streaming_logs**: Records streaming events with watch time and completion percentage

See `sql/init_edtech.sql` for the complete schema definition.

## 🔄 How It Works

1. The **simulator** service connects to the PostgreSQL database
2. Every 5 seconds, it randomly selects a student and classroom
3. New student records are inserted into the `students` table
4. Data is persisted and available for analytics
5. **Grafana** can query and visualize this data in real-time
6. **Airflow DAGs** run daily analytics on the collected data

## 📁 Project Structure

```
edtech-stream-automation/
├── docker-compose.yaml      # Docker Compose configuration
├── Dockerfile               # Simulator container definition
├── k8s-deployment.yaml      # Kubernetes deployment config
├── dags/
│   └── edtech_dag.py  # Airflow DAG for analytics
├── scripts/
│   └── edtech_simulator.py  # Main simulation script
└── sql/
    └── init_edtech.sql      # Database initialization script
```

## 🐳 Docker Services

### Database Service
- **Image**: `postgres:13`
- **Container**: `edtech_db`
- **Data Persistence**: Volume `postgres_data`

### Simulator Service
- **Image**: Built from local Dockerfile
- **Container**: `edtech_simulator`
- **Dependencies**: Waits for database to be ready

### Grafana Service
- **Image**: `grafana/grafana:latest`
- **Container**: `edtech_grafana`
- **Port**: `3000:3000`

## ☸️ Kubernetes Deployment

For production deployment using Kubernetes:

```bash
kubectl apply -f k8s-deployment.yaml
```

The deployment creates 2 replicas of the simulator service for high availability.

## 🔧 Configuration

### Environment Variables

The simulator uses the following environment variables (configured in `docker-compose.yaml`):

- `DB_HOST`: Database hostname (default: `db`)
- `DB_NAME`: Database name (default: `edtech_db`)
- `DB_USER`: Database user (default: `admin`)
- `DB_PASS`: Database password (default: `password`)

### Customization

- **Simulation Interval**: Modify `time.sleep(5)` in `scripts/edtech_simulator.py` to change the data generation frequency
- **Student Names**: Edit the `names` list in the simulator script
- **Classrooms**: Modify the `classrooms` list to add/remove classes

## 📈 Monitoring & Analytics

### Grafana Dashboards

The system includes a pre-configured **System Performance & Health Monitoring** dashboard that automatically loads when Grafana starts. The dashboard monitors:
- Database connections and performance
- Query performance metrics
- Database size and health status
- System uptime and active queries
- Data ingestion rates
- Table sizes and storage metrics

### Airflow Analytics

The included Airflow DAG (`edtech_dag.py`) runs daily to:
- Calculate average completion rates
- Analyze student engagement metrics
- Generate reports for teachers

## 🛑 Stopping the Services

```bash
docker-compose down
```

To remove volumes (⚠️ this will delete all data):
```bash
docker-compose down -v
```

## 🧪 Testing

Check if the simulator is generating data:

```bash
docker logs edtech_simulator
```

Query the database directly:

```bash
docker exec -it edtech_db psql -U admin -d edtech_db -c "SELECT COUNT(*) FROM students;"
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 👥 Authors

- Dalanda

## 🙏 Acknowledgments

- Built for educational purposes
- Demonstrates modern DevOps and data engineering practices

---

**Note**: This is a simulation system for educational purposes. For production use, ensure proper security configurations, especially for database credentials and network access.

