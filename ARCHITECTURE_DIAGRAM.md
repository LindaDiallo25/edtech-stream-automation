# Architecture Diagram
## EdTech Stream Automation Platform

## System Architecture Overview

This document contains visual architecture diagrams for the EdTech Stream Automation platform.

---

## 1. High-Level Architecture Diagram

### Mermaid Diagram (for GitHub/Markdown)

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

---

## 2. Detailed Component Architecture

### Mermaid Diagram

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

---

## 3. Data Flow Architecture

### Mermaid Diagram

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

---

## 4. Network Architecture

### Mermaid Diagram

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

---

## 5. Deployment Architecture

### Mermaid Diagram

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

## 6. Text-Based Architecture Description (for PowerPoint/Google Slides)

### Slide 1: System Overview

**Title:** EdTech Stream Automation - System Architecture

**Components:**
- **Data Layer:** PostgreSQL Database (edtech_db)
- **Application Layer:** EdTech Simulator (2 replicas)
- **Orchestration Layer:** Apache Airflow (Webserver + Scheduler)
- **Monitoring Layer:** Grafana Dashboard
- **Infrastructure:** On-Premise Kubernetes Cluster

### Slide 2: Component Details

**PostgreSQL Database:**
- Stores: students, lessons, streaming_logs
- Port: 5432 (internal only)
- Persistent Volume: 10GB

**EdTech Simulator:**
- Replicas: 2
- Function: Continuous data generation
- Rate: 12 records/min per replica

**Apache Airflow:**
- Webserver: Port 8080 (external access)
- Scheduler: Daily analytics DAG execution
- Database: Separate PostgreSQL for metadata

**Grafana:**
- Port: 3000 (external access)
- Function: System performance monitoring
- Dashboards: Pre-provisioned

### Slide 3: Data Flow

1. **Data Ingestion:**
   - Simulator replicas insert student records every 5 seconds
   - Data stored in PostgreSQL database

2. **Analytics Processing:**
   - Airflow scheduler runs daily DAG
   - Analyzes student engagement, lesson completion, classroom performance
   - Generates daily reports

3. **Monitoring:**
   - Grafana queries database for system metrics
   - Real-time dashboard updates
   - Performance and health monitoring

### Slide 4: Network Architecture

**Internal Services (ClusterIP):**
- Database: db-service:5432
- Simulator: simulator-service:80

**External Services (LoadBalancer):**
- Grafana: grafana-service:3000
- Airflow: airflow-webserver-service:8080

**Security:**
- Database not exposed externally
- Internal network communication only
- External access limited to monitoring and orchestration UIs

### Slide 5: Deployment Environments

**Development:**
- Docker Compose
- Local machine deployment
- All services in single compose file

**Production:**
- Kubernetes cluster
- On-premise infrastructure
- High availability with replicas
- Persistent storage for databases

---

## 7. How to Use These Diagrams

### Option 1: Mermaid (Recommended)
1. Copy the Mermaid code blocks
2. Paste into:
   - GitHub Markdown files (renders automatically)
   - Mermaid Live Editor: https://mermaid.live
   - VS Code with Mermaid extension
   - Any Markdown viewer that supports Mermaid

### Option 2: PowerPoint/Google Slides
1. Use the text descriptions in Section 6
2. Create slides with the component information
3. Use shapes and arrows to create visual diagrams
4. Recommended tools:
   - PowerPoint: Insert > SmartArt or Shapes
   - Google Slides: Insert > Diagram
   - Draw.io: https://app.diagrams.net (free online)

### Option 3: Export from Mermaid
1. Go to https://mermaid.live
2. Paste Mermaid code
3. Export as PNG, SVG, or PDF
4. Insert into PowerPoint/Google Slides

---

## 8. Visual Elements Guide

**Color Coding:**
- **Blue (#336791):** Database services
- **Green (#4CAF50):** Application/Simulator services
- **Orange (#F46800):** Monitoring/Grafana
- **Light Blue (#017CEE):** Orchestration/Airflow
- **Red (#ff6b6b):** Internal-only services
- **Green (#51cf66):** External-accessible services

**Shapes:**
- **Cylinder:** Database/Persistent Storage
- **Rectangle:** Application Services
- **Rounded Rectangle:** Kubernetes Pods
- **Cloud:** Network/Infrastructure

---

**Document Status:** Complete  
**Last Updated:** January 2025  
**Format:** Mermaid diagrams + Text descriptions for PowerPoint/Google Slides

