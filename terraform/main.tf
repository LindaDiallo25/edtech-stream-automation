# Get the latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-v*/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for the EdTech instance
resource "aws_security_group" "edtech" {
  name_prefix = "edtech-"
  description = "Security group for EdTech stream automation infrastructure"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH access
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # PostgreSQL
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Grafana
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Airflow
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Prometheus
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.instance_name}-sg"
    Environment = var.environment
  }
}

# IAM Role for EC2 instance
resource "aws_iam_role" "edtech_role" {
  name_prefix = "edtech-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# IAM Role Policy for CloudWatch and Systems Manager
resource "aws_iam_role_policy_attachment" "edtech_policy" {
  role       = aws_iam_role.edtech_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "edtech_profile" {
  name_prefix = "edtech-"
  role        = aws_iam_role.edtech_role.name
}

# EC2 Instance
resource "aws_instance" "edtech" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.edtech_profile.name
  vpc_security_group_ids = [aws_security_group.edtech.id]
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 50
    delete_on_termination = true
  }

  # User data script to install Docker and Docker Compose
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    postgres_password    = var.postgres_password
    postgres_user        = var.postgres_user
    postgres_db          = var.postgres_db
    airflow_db_password  = var.airflow_db_password
    airflow_db_user      = var.airflow_db_user
    airflow_db_name      = var.airflow_db_name
    grafana_admin_pass   = var.grafana_admin_password
  }))

  monitoring = true

  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }

  depends_on = [aws_security_group.edtech]
}

# Elastic IP for the instance
resource "aws_eip" "edtech" {
  instance = aws_instance.edtech.id
  domain   = "vpc"

  tags = {
    Name        = "${var.instance_name}-eip"
    Environment = var.environment
  }

  depends_on = [aws_instance.edtech]
}
