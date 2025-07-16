terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.region
}

# Obtener la AMI más reciente de Amazon Linux
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Obtener la VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Obtener subnets de la VPC por defecto
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Generar un ID único para recursos
resource "random_string" "resource_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Generar contraseña para la base de datos
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Security Group para EC2
resource "aws_security_group" "web_sg" {
  name_prefix = "${var.project_name}-web-"
  description = "Security group para servidor web"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow port ${ingress.value}"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-web-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Security Group para RDS
resource "aws_security_group" "rds_sg" {
  name_prefix = "${var.project_name}-rds-"
  description = "Security group for RDS database"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
    description     = "MySQL access from web servers"
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Bucket S3
resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.project_name}-${var.environment}-${random_string.resource_suffix.result}"
  
  tags = {
    Name        = "${var.project_name} App Bucket"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "app_bucket_pab" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name        = "${var.project_name} DB subnet group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Base de datos RDS
resource "aws_db_instance" "app_db" {
  identifier                = "${var.project_name}-${var.environment}"
  allocated_storage         = 20
  max_allocated_storage     = 100
  storage_type              = "gp2"
  engine                    = "mysql"
  engine_version            = "8.0"
  instance_class            = "db.t3.micro"
  
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name        = "${var.project_name} Database"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Instancia EC2 con servidor web
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd mysql
              systemctl start httpd
              systemctl enable httpd
              
              # Crear página web simple
              cat > /var/www/html/index.html << 'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>${var.project_name} - Creado con Terraform</title>
                  <style>
                      body { font-family: Arial, sans-serif; margin: 40px; }
                      .container { max-width: 800px; margin: 0 auto; }
                      .status { background: #e8f5e8; padding: 20px; border-radius: 5px; }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>🚀 ${var.project_name}</h1>
                      <div class="status">
                          <h2>✅ Infraestructura Desplegada</h2>
                          <p><strong>Entorno:</strong> ${var.environment}</p>
                          <p><strong>Servidor web:</strong> Funcionando</p>
                          <p><strong>Base de datos:</strong> Configurada</p>
                          <p><strong>Almacenamiento:</strong> S3 Bucket creado</p>
                      </div>
                      <h3>Recursos creados:</h3>
                      <ul>
                          <li>Servidor EC2 con Apache</li>
                          <li>Base de datos MySQL RDS</li>
                          <li>Bucket S3 para almacenamiento</li>
                          <li>Security Groups configurados</li>
                      </ul>
                  </div>
              </body>
              </html>
HTML
              EOF

  tags = {
    Name        = "${var.project_name} Web Server"
    Environment = var.environment
    Project     = var.project_name
  }
}