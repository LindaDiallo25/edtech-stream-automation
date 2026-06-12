output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.edtech.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.edtech.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_eip.edtech.public_dns
}

output "grafana_url" {
  description = "Grafana endpoint URL"
  value       = "http://${aws_eip.edtech.public_ip}:3000"
}

output "airflow_url" {
  description = "Airflow webserver endpoint URL"
  value       = "http://${aws_eip.edtech.public_ip}:8080"
}

output "prometheus_url" {
  description = "Prometheus endpoint URL"
  value       = "http://${aws_eip.edtech.public_ip}:9090"
}

output "postgres_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgres://${var.postgres_user}:${var.postgres_password}@${aws_eip.edtech.public_ip}:5432/${var.postgres_db}"
  sensitive   = true
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.edtech.id
}

