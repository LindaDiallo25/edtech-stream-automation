locals {
  root_path = abspath(path.module)
}

resource "docker_network" "edtech" {
  name = "edtech-network"
}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

resource "docker_volume" "airflow_db_data" {
  name = "airflow_db_data"
}

resource "docker_image" "postgres" {
  name = "postgres:13"
}

resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_image" "airflow" {
  name = "apache/airflow:2.8.0"
}

resource "docker_image" "redis" {
  name = "redis:7-alpine"
}

resource "docker_image" "simulator" {
  name = "edtech_simulator:latest"

  build {
    context    = "${local.root_path}/.."
    dockerfile = "${local.root_path}/../Dockerfile"
  }
}

resource "docker_container" "db" {
  name  = "edtech_db"
  image = docker_image.postgres.latest

  env = [
    "POSTGRES_DB=${var.postgres_db}",
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
  ]

  ports {
    internal = 5432
    external = 5432
  }

  volumes = [
    "${docker_volume.postgres_data.name}:/var/lib/postgresql/data",
    "${local.root_path}/../sql/init_edtech.sql:/docker-entrypoint-initdb.d/init_edtech.sql",
  ]

  networks_advanced {
    name = docker_network.edtech.name
  }
}

resource "docker_container" "simulator" {
  name  = "edtech_simulator"
  image = docker_image.simulator.latest

  env = [
    "DB_HOST=${docker_container.db.name}",
    "DB_NAME=${var.postgres_db}",
    "DB_USER=${var.postgres_user}",
    "DB_PASS=${var.postgres_password}",
  ]

  networks_advanced {
    name = docker_network.edtech.name
  }

  depends_on = [
    docker_container.db,
  ]
}

resource "docker_container" "grafana" {
  name  = "edtech_grafana"
  image = docker_image.grafana.latest

  env = [
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
  ]

  ports {
    internal = 3000
    external = 3000
  }

  volumes = [
    "${local.root_path}/../grafana/provisioning:/etc/grafana/provisioning",
    "${local.root_path}/../grafana/dashboards:/var/lib/grafana/dashboards",
  ]

  networks_advanced {
    name = docker_network.edtech.name
  }

  depends_on = [
    docker_container.db,
  ]
}

resource "docker_container" "airflow_db" {
  name  = "airflow_db"
  image = docker_image.postgres.latest

  env = [
    "POSTGRES_DB=${var.airflow_db_name}",
    "POSTGRES_USER=${var.airflow_db_user}",
    "POSTGRES_PASSWORD=${var.airflow_db_password}",
  ]

  volumes = [
    "${docker_volume.airflow_db_data.name}:/var/lib/postgresql/data",
  ]

  networks_advanced {
    name = docker_network.edtech.name
  }
}

resource "docker_container" "redis" {
  name  = "airflow_redis"
  image = docker_image.redis.latest

  networks_advanced {
    name = docker_network.edtech.name
  }
}

resource "docker_container" "airflow_webserver" {
  name  = "airflow-webserver"
  image = docker_image.airflow.latest

  env = [
    "AIRFLOW__CORE__EXECUTOR=LocalExecutor",
    "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://${var.airflow_db_user}:${var.airflow_db_password}@${docker_container.airflow_db.name}/${var.airflow_db_name}",
    "AIRFLOW__CORE__FERNET_KEY=5U4u0Csw67u8MQXgqEFvL4jY41KWGe3C9PnXSQk3vo=",
    "AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=true",
    "AIRFLOW__CORE__LOAD_EXAMPLES=false",
    "AIRFLOW_UID=1000",
    "AIRFLOW__API__AUTH_BACKENDS=airflow.api.auth.backend.basic_auth",
    "AIRFLOW__WEBSERVER__EXPOSE_CONFIG=true",
    "_PIP_ADDITIONAL_REQUIREMENTS=psycopg2-binary",
  ]

  ports {
    internal = 8080
    external = 8080
  }

  volumes = [
    "${local.root_path}/../dags:/opt/airflow/dags",
    "${local.root_path}/../logs:/opt/airflow/logs",
    "${local.root_path}/../plugins:/opt/airflow/plugins",
  ]

  networks_advanced {
    name = docker_network.edtech.name
  }

  depends_on = [
    docker_container.airflow_db,
    docker_container.redis,
  ]
}

resource "docker_container" "airflow_scheduler" {
  name  = "airflow-scheduler"
  image = docker_image.airflow.latest

  env = [
    "AIRFLOW__CORE__EXECUTOR=LocalExecutor",
    "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://${var.airflow_db_user}:${var.airflow_db_password}@${docker_container.airflow_db.name}/${var.airflow_db_name}",
    "AIRFLOW__CORE__FERNET_KEY=5U4u0Csw67u8MQXgqEFvL4jY41KWGe3C9PnXSQk3vo=",
    "AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=true",
    "AIRFLOW__CORE__LOAD_EXAMPLES=false",
    "AIRFLOW_UID=1000",
    "AIRFLOW__API__AUTH_BACKENDS=airflow.api.auth.backend.basic_auth",
    "_PIP_ADDITIONAL_REQUIREMENTS=psycopg2-binary",
  ]

  volumes = [
    "${local.root_path}/../dags:/opt/airflow/dags",
    "${local.root_path}/../logs:/opt/airflow/logs",
    "${local.root_path}/../plugins:/opt/airflow/plugins",
  ]

  networks_advanced {
    name = docker_network.edtech.name
  }

  depends_on = [
    docker_container.airflow_db,
    docker_container.redis,
  ]
}
