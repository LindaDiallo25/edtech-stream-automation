variable "aws_region" {
  description = "AWS region to deploy the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "edtech-stream-automation"
}

variable "environment" {
  description = "Environment tag for the infrastructure"
  type        = string
  default     = "development"
}

variable "postgres_password" {
  description = "Password for the PostgreSQL database."
  type        = string
  default     = "password"
  sensitive   = true
}

variable "postgres_user" {
  description = "Username for the PostgreSQL database."
  type        = string
  default     = "admin"
}

variable "postgres_db" {
  description = "Database name for the EdTech application."
  type        = string
  default     = "edtech_db"
}

variable "airflow_db_password" {
  description = "Password for the Airflow PostgreSQL metadata database."
  type        = string
  default     = "airflow"
  sensitive   = true
}

variable "airflow_db_user" {
  description = "Username for the Airflow PostgreSQL metadata database."
  type        = string
  default     = "airflow"
}

variable "airflow_db_name" {
  description = "Name of the Airflow metadata database."
  type        = string
  default     = "airflow_db"
}

variable "grafana_admin_password" {
  description = "Grafana admin user password."
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "project_root" {
  description = "Path to the repository root from the Terraform module."
  type        = string
  default     = ".."
}

