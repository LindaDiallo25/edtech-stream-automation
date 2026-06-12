# Architecture Requirements Document
## EdTech Stream Automation Platform

**Project:** EdTech Stream Automation
**Deployment Environment:** **On-Premise**

---

## 1. Executive Summary

This document describes the architecture of the EdTech Stream Automation platform, an on-premise data infrastructure solution for educational streaming analytics. The platform simulates student streaming behavior, captures engagement events, stores data in PostgreSQL, runs automated analytics with Apache Airflow, and provides observability through Grafana and Prometheus.

**Deployment Approach:**
- **Development:** Docker Compose for local testing and rapid iteration
- **Production:** Kubernetes on on-premise infrastructure
- **Optional Infrastructure Provisioning:** Terraform example for AWS EC2

---

## 2. Business Objectives

### 2.1 Goals

1. **Data Collection & Simulation**
   - Generate realistic student streaming events for analytics
   - Maintain continuous data ingestion
   - Support multiple classrooms and lesson types

2. **Analytics & Reporting**
   - Execute scheduled analytics workflows daily
   - Track lesson completion and student engagement
   - Provide insights for educators and administrators

3. **Monitoring & Reliability**
   - Measure service health and performance in real time
   - Alert on critical failures and resource issues
   - Ensure operational stability across the infrastructure

4. **Scalability & Maintainability**
   - Scale simulation horizontally
   - Enable repeatable deployments with infrastructure as code
   - Keep the architecture easy to extend and maintain

### 2.2 Stakeholders

- **Educators:** Need engagement metrics and lesson effectiveness reports
- **Administrators:** Require monitoring and reliability controls
- **Data Engineers:** Need reliable pipelines, storage, and analytics automation
- **Developers:** Need simple deployment, monitoring, and observability

---

## 3. Architecture Overview

The system is designed as a modular container-based platform with the following layers:

- **Data Layer:** PostgreSQL for application and metadata storage
- **Ingestion Layer:** Simulator container generating streaming events
- **Orchestration Layer:** Apache Airflow for scheduled analytics workflows
- **Observability Layer:** Grafana dashboards and Prometheus metrics
- **Infrastructure Layer:** Docker Compose for local use, Kubernetes for production

Key design principles:
- **Containerization:** All services run in containers for consistency
- **Separation of concerns:** Each component has a focused responsibility
- **Observability:** Monitoring and alerts are integral to the architecture
- **On-premise deployment:** Designed to run inside private infrastructure without cloud dependency

---

## 4. Architecture Diagrams

### 4.1 High-Level Architecture

```mermaid
graph TB
    subgraph "On-Premise Infrastructure"
        subgraph "Kubernetes Cluster"
            subgraph "Data Layer"
                DB[(PostgreSQL<br/>Database<br/>edtech_db)]
                AIRFLOW_DB[(PostgreSQL<br/>Airflow Metadata)]
            end
            
            subgraph "Application Layer"
                SIM1[Simulator<br/>Replica 1]
                SIM2[Simulator<br/>Replica 2]
            end
            
            subgraph "Orchestration Layer"
                AIRFLOW_WS[Airflow<br/>Webserver<br/>:8080]
                AIRFLOW_SCHED[Airflow<br/>Scheduler]
            end
            
            subgraph "Monitoring Layer"
                GRAFANA[Grafana<br/>Dashboard<br/>:3000]
            end
        end
        
        subgraph "External Access"
            USER[Users/Administrators]
        end
    end
    
    SIM1 -->|Insert Data| DB
    SIM2 -->|Insert Data| DB
    AIRFLOW_SCHED -->|Read/Analyze| DB
    GRAFANA -->|Query Metrics| DB
    AIRFLOW_WS -->|Metadata| AIRFLOW_DB
    AIRFLOW_SCHED -->|Metadata| AIRFLOW_DB
    USER -->|Access Dashboard| GRAFANA
    USER -->|Access UI| AIRFLOW_WS
    
    style DB fill:#336791,stroke:#fff,color:#fff
    style AIRFLOW_DB fill:#336791,stroke:#fff,color:#fff
    style SIM1 fill:#4CAF50,stroke:#fff,color:#fff
    style SIM2 fill:#4CAF50,stroke:#fff,color:#fff
    style GRAFANA fill:#F46800,stroke:#fff,color:#fff
    style AIRFLOW_WS fill:#017CEE,stroke:#fff,color:#fff
    style AIRFLOW_SCHED fill:#017CEE,stroke:#fff,color:#fff
```

### 4.2 Detailed Component Architecture

```mermaid
graph LR
    subgraph "On-Premise Kubernetes Cluster"
        subgraph "Namespace: default"
            subgraph "Database Services"
                DB_POD[PostgreSQL Pod<br/>Container: postgres:13<br/>Volume: postgres-data]
                DB_SVC[db-service<br/>ClusterIP:5432]
            end
            
            subgraph "Simulator Services"
                SIM_POD1[Simulator Pod 1<br/>Container: edtech-simulator<br/>Replica 1]
                SIM_POD2[Simulator Pod 2<br/>Container: edtech-simulator<br/>Replica 2]
                SIM_SVC[simulator-service<br/>ClusterIP:80]
            end
            
            subgraph "Airflow Services"
                AF_WS_POD[Airflow Webserver Pod<br/>Container: apache/airflow:2.8.0<br/>Port: 8080]
                AF_SCHED_POD[Airflow Scheduler Pod<br/>Container: apache/airflow:2.8.0]
                AF_DB_POD[Airflow DB Pod<br/>Container: postgres:13<br/>Volume: airflow-db-data]
                AF_WS_SVC[airflow-webserver-service<br/>LoadBalancer:8080]
            end
            
            subgraph "Monitoring Services"
                GRAFANA_POD[Grafana Pod<br/>Container: grafana/grafana<br/>Port: 3000]
                GRAFANA_SVC[grafana-service<br/>LoadBalancer:3000]
            end
        end
    end
    
    SIM_POD1 -->|INSERT students| DB_POD
    SIM_POD2 -->|INSERT students| DB_POD
    SIM_POD1 -.->|via| DB_SVC
    SIM_POD2 -.->|via| DB_SVC
    
    AF_SCHED_POD -->|SELECT/ANALYZE| DB_POD
    AF_SCHED_POD -.->|via| DB_SVC
    AF_WS_POD -->|Metadata| AF_DB_POD
    AF_SCHED_POD -->|Metadata| AF_DB_POD
    
    GRAFANA_POD -->|Query Metrics| DB_POD
    GRAFANA_POD -.->|via| DB_SVC
    
    style DB_POD fill:#336791,stroke:#fff,color:#fff
    style AF_DB_POD fill:#336791,stroke:#fff,color:#fff
    style SIM_POD1 fill:#4CAF50,stroke:#fff,color:#fff
    style SIM_POD2 fill:#4CAF50,stroke:#fff,color:#fff
    style GRAFANA_POD fill:#F46800,stroke:#fff,color:#fff
    style AF_WS_POD fill:#017CEE,stroke:#fff,color:#fff
    style AF_SCHED_POD fill:#017CEE,stroke:#fff,color:#fff
```

### 4.3 Data Flow Architecture

```mermaid
sequenceDiagram
    participant S1 as Simulator Replica 1
    participant S2 as Simulator Replica 2
    participant DB as PostgreSQL Database
    participant AF as Airflow Scheduler
    participant GRAF as Grafana
    participant USER as Administrator
    
    Note over S1,S2: Continuous Data Ingestion
    loop Every 5 seconds
        S1->>DB: INSERT student record
        S2->>DB: INSERT student record
    end
    
    Note over AF: Daily Analytics (Scheduled)
    AF->>DB: SELECT students, streaming_logs
    AF->>DB: Calculate engagement metrics
    AF->>DB: Generate daily report
    
    Note over GRAF,USER: Real-time Monitoring
    USER->>GRAF: Access Dashboard
    GRAF->>DB: Query system metrics
    DB-->>GRAF: Return performance data
    GRAF-->>USER: Display metrics
```

### 4.4 Network Architecture

```mermaid
graph TB
    subgraph "On-Premise Network"
        subgraph "Kubernetes Internal Network"
            subgraph "ClusterIP Services"
                DB_SVC[db-service:5432<br/>Internal Only]
                SIM_SVC[simulator-service:80<br/>Internal Only]
            end
            
            subgraph "LoadBalancer Services"
                GRAF_SVC[grafana-service:3000<br/>External Access]
                AF_SVC[airflow-webserver-service:8080<br/>External Access]
            end
        end
        
        subgraph "External Access"
            EXT_USER[Users/Administrators<br/>Internal Network]
        end
    end
    
    EXT_USER -->|HTTP :3000| GRAF_SVC
    EXT_USER -->|HTTP :8080| AF_SVC
    
    DB_SVC -.->|Blocked| EXT_USER
    SIM_SVC -.->|Blocked| EXT_USER
    
    style DB_SVC fill:#ff6b6b,stroke:#fff,color:#fff
    style SIM_SVC fill:#ff6b6b,stroke:#fff,color:#fff
    style GRAF_SVC fill:#51cf66,stroke:#fff,color:#fff
    style AF_SVC fill:#51cf66,stroke:#fff,color:#fff
```

### 4.5 Deployment Architecture

```mermaid
graph TB
    subgraph "On-Premise Infrastructure"
        subgraph "Development Environment"
            DC[Docker Compose<br/>Local Development]
            DC_DB[(PostgreSQL)]
            DC_SIM[Simulator]
            DC_GRAF[Grafana]
            DC_AF[Airflow]
        end
        
        subgraph "Production Environment"
            K8S[Kubernetes Cluster<br/>On-Premise]
            K8S_DB[(PostgreSQL<br/>Persistent Volume)]
            K8S_SIM[Simulator<br/>2 Replicas]
            K8S_GRAF[Grafana<br/>1 Replica]
            K8S_AF[Airflow<br/>Webserver + Scheduler]
        end
    end
    
    DC --> DC_DB
    DC --> DC_SIM
    DC --> DC_GRAF
    DC --> DC_AF
    K8S --> K8S_DB
    K8S --> K8S_SIM
    K8S --> K8S_GRAF
    K8S --> K8S_AF
    
    style DC fill:#ffd43b,stroke:#000
    style K8S fill:#4CAF50,stroke:#fff,color:#fff
```

---

## 5. System Components

### 5.1 Core Services

1. **PostgreSQL Database**
   - Stores: students, lessons, streaming_logs
   - Purpose: persistent storage and analytics queries
   - Access: internal network only

2. **EdTech Simulator**
   - Generates: student and streaming event records
   - Frequency: every 5 seconds
   - Purpose: continuous ingestion for analytics testing

3. **Apache Airflow**
   - Components: webserver, scheduler, metadata database
   - Purpose: orchestrates analytics DAGs and reporting
   - Schedule: daily job execution

4. **Grafana**
   - Purpose: visualization and dashboard monitoring
   - Port: 3000
   - Includes: pre-provisioned dashboards and datasources

5. **Prometheus**
   - Purpose: metric collection and alert evaluation
   - Port: 9090
   - Scrapes: PostgreSQL, Airflow, Docker, and self metrics

6. **Terraform / AWS EC2**
   - Purpose: optional infrastructure provisioning example
   - Deploys: single EC2 instance with Docker bootstrap

---

## 6. Non-Functional Requirements

### 6.1 Performance

- Support at least 12 records per minute per simulator replica
- Maintain dashboard queries under 2 seconds
- Complete analytics DAG runs within 5 minutes

### 6.2 Scalability

- Support horizontal scaling of simulator replicas
- Provide database scaling options through resource allocation
- Use Kubernetes load balancing for production services

### 6.3 Reliability

- Target 99.5% uptime
- Restart failed containers automatically
- Preserve data with persistent volumes

### 6.4 Maintainability

- Document architecture and deployment clearly
- Keep code modular and easy to extend
- Use environment variables for configuration

---

## 7. Risk Assessment & Mitigation

### 7.1 Infrastructure Risks

- **Database failure**: use persistent volumes and restart policies
- **High data volume**: apply indexes and optimize queries
- **Dependency failure**: implement health checks and retries
- **Resource exhaustion**: set limits and monitor usage

### 7.2 Security Risks

- **Exposed credentials**: avoid hardcoded passwords and use environment variables
- **Network exposure**: lock down internal services and limit external ports

---

## 8. Future Considerations

- Add real-time stream processing with Kafka or similar
- Extend monitoring with node_exporter and alertmanager
- Add a separate analytics warehouse for reporting
- Implement API access for external integrations
- Add stronger authentication and authorization

---

## 9. Conclusion

This architecture document now combines requirements, design decisions, diagrams, and deployment patterns for the EdTech Stream Automation platform. The solution supports a full on-premise deployment model with Docker Compose for development and Kubernetes for production, while preserving a strong focus on observability, scalability, and maintainability.

The design supports:
- **Reliable data ingestion**
- **Daily analytics workflows**
- **Monitoring and alerting**
- **Scalable on-premise deployment**
- **Clear separation between development and production environments**

This architecture is ready to support the current project requirements and future growth.
