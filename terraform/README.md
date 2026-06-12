# Terraform AWS Deployment

This directory contains Terraform configuration for provisioning the EdTech Stream Automation stack on AWS using EC2.

## Prerequisites

- AWS account with credentials configured
- Terraform 1.5 or later
- AWS CLI configured

```bash
aws configure
```

## What this deployment creates

- **EC2 instance** running Ubuntu
- **Security group** allowing SSH, PostgreSQL, Grafana, Airflow, and Prometheus ports
- **IAM role** and instance profile
- **Elastic IP** for a stable public address
- **User data script** that bootstraps Docker, Docker Compose, and deploys the stack

## Important variables

Provide values by creating `terraform.tfvars` or exporting environment variables. Example values:

```hcl
aws_region              = "us-east-1"
instance_type           = "t3.medium"
instance_name           = "edtech-stream-automation"
environment             = "development"
postgres_password       = "your-secure-password"
postgres_user           = "admin"
postgres_db             = "edtech_db"
airflow_db_password     = "your-secure-airflow-password"
airflow_db_user         = "airflow"
airflow_db_name         = "airflow_db"
grafana_admin_password  = "your-secure-grafana-password"
```

## Usage

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Review the plan

```bash
terraform plan
```

### 3. Apply the stack

```bash
terraform apply
```

### 4. Destroy the stack

```bash
terraform destroy
```

## Accessing services

Terraform outputs include the public IP and service URLs, such as:

- Grafana: `http://<public-ip>:3000`
- Airflow: `http://<public-ip>:8080`
- Prometheus: `http://<public-ip>:9090`

## Verification

SSH into the instance and check Docker Compose status:

```bash
ssh -i your-key.pem ubuntu@<public-ip>
docker-compose ps
docker-compose logs
```

## Notes

- Bootstrap may take several minutes to complete.
- Security group rules are broad by default; restrict them for production use.
- Destroy resources after use to avoid AWS charges.
