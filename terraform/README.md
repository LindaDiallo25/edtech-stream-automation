# Terraform AWS Deployment

This directory contains Terraform configuration for provisioning the EdTech stream automation infrastructure on AWS using EC2.

## Prerequisites

- AWS account with appropriate credentials configured
- Terraform 1.5 or later
- AWS CLI configured with credentials

```bash
aws configure
```

## Architecture

The Terraform configuration deploys:

- **EC2 Instance**: Ubuntu 24.04 LTS (t3.medium by default)
- **Security Group**: Allows SSH (22), PostgreSQL (5432), Grafana (3000), Airflow (8080), and Prometheus (9090)
- **IAM Role**: For instance to access AWS services
- **Elastic IP**: Static public IP for the instance
- **User Data Script**: Bootstraps the instance with Docker and Docker Compose, then deploys the full stack

### Services Running on the Instance

Once deployed, the following services run via Docker Compose inside the EC2 instance:

- PostgreSQL (edtech_db + airflow_db)
- Grafana dashboard
- Apache Airflow (webserver + scheduler)
- Redis cache
- EdTech data simulator
- Prometheus monitoring
- Alerting system

## Configuration Variables

Create a `terraform.tfvars` file or export variables:

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

### 2. Review the Deployment Plan

```bash
terraform plan
```

This shows all resources that will be created on AWS.

### 3. Deploy to AWS

```bash
terraform apply
```

**Note**: This will spin up an EC2 instance, so you will incur AWS charges. The user data script takes a few minutes to complete the deployment.

### 4. Access the Services

Once deployed, Terraform outputs will show the public IP and service URLs:

```
Outputs:
instance_public_ip = "X.X.X.X"
grafana_url = "http://X.X.X.X:3000"
airflow_url = "http://X.X.X.X:8080"
prometheus_url = "http://X.X.X.X:9090"
postgres_connection_string = "postgres://..."
```

### 5. Verify Deployment Status

SSH into the instance to check deployment progress:

```bash
ssh -i your-key-pair.pem ubuntu@<public-ip>
```

Check Docker Compose status:

```bash
docker-compose ps
docker-compose logs
```

### 6. Destroy Resources

When finished, remove all resources and stop AWS charges:

```bash
terraform destroy
```

## Important Notes

- **Initial Deployment**: The EC2 instance takes 3-5 minutes to fully bootstrap and deploy all services. Check `/var/log/edtech-deployment.log` on the instance for progress.
- **Security**: The security group allows public access to all service ports. For production, restrict source IPs to your organization's IP ranges.
- **Costs**: Running a t3.medium instance in us-east-1 typically costs ~$0.04/hour. Remember to destroy resources when not in use.
- **SSH Access**: Ensure you have a valid EC2 key pair to SSH into the instance.
- **Repository Access**: The user data script attempts to clone the repository. Ensure the GitHub repository is accessible from the EC2 instance.

## AWS Resources Created

- `aws_instance`: EC2 instance running the application stack
- `aws_security_group`: Network security configuration
- `aws_eip`: Elastic IP for static public addressing
- `aws_iam_role`: IAM role for EC2 instance
- `aws_iam_instance_profile`: Instance profile linking the IAM role
- `aws_iam_role_policy_attachment`: CloudWatch permissions for monitoring

## Troubleshooting

### Deployment Failed

Check the user data logs on the instance:

```bash
ssh ubuntu@<public-ip>
tail -f /var/log/edtech-deployment.log
tail -f /var/log/cloud-init-output.log
```

### Services Not Starting

SSH into the instance and check Docker Compose:

```bash
docker-compose ps
docker-compose logs -f
```

### Database Connection Issues

Verify the Elastic IP is correctly associated:

```bash
terraform output instance_public_ip
```

## Next Steps

- Customize instance type in `terraform.tfvars` (e.g., `t3.large` for more resources)
- Add additional security group rules for specific IP ranges
- Configure automated backups for persistent volumes
- Set up Route53 DNS for your domain

