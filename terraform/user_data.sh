#!/bin/bash
set -e

# Update system packages
apt-get update
apt-get upgrade -y

# Install Docker
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Install Docker Compose v1 (standalone)
curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start Docker service
systemctl enable docker
systemctl start docker

# Clone or download the repository
cd /opt
if [ ! -d "edtech-stream-automation" ]; then
  git clone https://github.com/LindaDiallo25/edtech-stream-automation.git || echo "Note: Repository cloning failed - manual setup required"
fi

cd /opt/edtech-stream-automation || cd /tmp

# Create docker-compose environment file
cat > .env << EOF
POSTGRES_DB=${postgres_db}
POSTGRES_USER=${postgres_user}
POSTGRES_PASSWORD=${postgres_password}
AIRFLOW_DB_NAME=${airflow_db_name}
AIRFLOW_DB_USER=${airflow_db_user}
AIRFLOW_DB_PASSWORD=${airflow_db_password}
GF_SECURITY_ADMIN_PASSWORD=${grafana_admin_pass}
AIRFLOW_UID=1000
AIRFLOW_GID=0
EOF

# Deploy the stack using docker-compose
if [ -f "docker-compose.yaml" ]; then
  docker-compose up -d
  echo "Docker Compose stack deployed successfully"
else
  echo "Warning: docker-compose.yaml not found"
fi

# Log deployment completion
echo "EdTech stream automation deployment completed at $(date)" > /var/log/edtech-deployment.log
