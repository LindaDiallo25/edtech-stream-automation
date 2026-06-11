output "postgres_container_name" {
  description = "Name of the PostgreSQL container."
  value       = docker_container.db.name
}

output "grafana_url" {
  description = "Grafana endpoint for local deployment."
  value       = "http://localhost:3000"
}

output "airflow_url" {
  description = "Airflow webserver endpoint for local deployment."
  value       = "http://localhost:8080"
}

output "simulator_container_name" {
  description = "Name of the simulator container."
  value       = docker_container.simulator.name
}
