variable "postgres_password" {
  description = "Password for the PostgreSQL database."
  type        = string
  default     = "password"
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
}

variable "project_root" {
  description = "Path to the repository root from the Terraform module."
  type        = string
  default     = ".."
}
