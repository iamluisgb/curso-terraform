# Laboratorio 3: Primeros Pasos con AWS y Terraform

## 🎯 Objetivos de Aprendizaje

Al completar este laboratorio serás capaz de:
- Configurar Terraform para trabajar con AWS
- Crear recursos básicos en AWS: EC2, S3, Security Groups y RDS
- Entender la importancia de las credenciales y regiones
- Aplicar buenas prácticas desde el primer día
- Limpiar recursos para evitar costos

## 📋 Prerrequisitos

- **Cuenta AWS** (tier gratuito es suficiente)
- **AWS CLI instalado** y configurado
- **Terraform instalado**
- **Credenciales AWS configuradas** (ver sección de configuración)

## ⚙️ Configuración Inicial

### 1. Configurar Credenciales AWS

Hay varias formas de configurar las credenciales. Elige una:

**Opción A: AWS CLI (Recomendado)**
```bash
aws configure
```

**Opción B: Variables de entorno**
```bash
export AWS_ACCESS_KEY_ID="tu-access-key"
export AWS_SECRET_ACCESS_KEY="tu-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

**Opción C: Archivo de credenciales**
Crea `~/.aws/credentials`:
```
[default]
aws_access_key_id = tu-access-key
aws_secret_access_key = tu-secret-key
```

### 2. Verificar Configuración
```bash
aws sts get-caller-identity
```

## 💡 Conceptos Importantes

- **Región**: Ubicación geográfica de AWS (us-east-1, eu-west-1, etc.)
- **AMI**: Imagen de máquina virtual preconfigurada
- **VPC**: Red virtual privada (Virtual Private Cloud)
- **Security Group**: Firewall para controlar tráfico
- **Tags**: Etiquetas para organizar recursos

---

## 🚀 Ejercicio 1: Tu Primera Instancia EC2

### Objetivo
Crear un servidor virtual básico en AWS.

### Paso a Paso

**1. Crea la estructura del proyecto:**
```
terraform-aws-ec2/
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

**2. Variables (`variables.tf`):**
```hcl
variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Nombre de la instancia EC2"
  type        = string
  default     = "mi-primera-instancia"
}

variable "environment" {
  description = "Entorno (dev, staging, prod)"
  type        = string
  default     = "dev"
}
```

**3. Configuración principal (`main.tf`):**
```hcl
# Configuración del provider AWS
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

# Crear la instancia EC2
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro" # Elegible para tier gratuito
  
  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = "terraform-learning"
    CreatedBy   = "terraform"
  }
}
```

**4. Outputs (`outputs.tf`):**
```hcl
output "instance_info" {
  description = "Información de la instancia EC2"
  value = {
    id         = aws_instance.web_server.id
    public_ip  = aws_instance.web_server.public_ip
    private_ip = aws_instance.web_server.private_ip
    az         = aws_instance.web_server.availability_zone
  }
}

output "connection_command" {
  description = "Comando para conectarse a la instancia"
  value       = "aws ec2 describe-instances --instance-ids ${aws_instance.web_server.id}"
}
```

**5. Valores (`terraform.tfvars`):**
```hcl
region        = "us-east-1"
instance_name = "mi-servidor-web"
environment   = "development"
```

**6. Ejecutar:**
```bash
terraform init
terraform plan
terraform apply
```

### 🧪 Experimentos
- Cambia la región a "us-west-2" y observa los cambios
- Modifica el nombre de la instancia
- Consulta la instancia en la consola AWS

---

## 📦 Ejercicio 2: Bucket S3 para Almacenamiento

### Objetivo
Crear almacenamiento en la nube para archivos.

**1. Estructura del proyecto:**
```
terraform-aws-s3/
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

**2. Variables (`variables.tf`):**
```hcl
variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Prefijo para el nombre del bucket"
  type        = string
  default     = "mi-bucket-terraform"
}

variable "environment" {
  description = "Entorno"
  type        = string
  default     = "dev"
}
```

**3. Configuración principal (`main.tf`):**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Generar un ID único para el bucket
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Crear el bucket S3
resource "aws_s3_bucket" "main_bucket" {
  bucket = "${var.bucket_prefix}-${var.environment}-${random_string.bucket_suffix.result}"
  
  tags = {
    Name        = "Bucket principal"
    Environment = var.environment
    Project     = "terraform-learning"
    CreatedBy   = "terraform"
  }
}

# Configurar versionado del bucket
resource "aws_s3_bucket_versioning" "main_bucket_versioning" {
  bucket = aws_s3_bucket.main_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bloquear acceso público por defecto
resource "aws_s3_bucket_public_access_block" "main_bucket_pab" {
  bucket = aws_s3_bucket.main_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

**4. Outputs (`outputs.tf`):**
```hcl
output "bucket_info" {
  description = "Información del bucket S3"
  value = {
    name   = aws_s3_bucket.main_bucket.bucket
    arn    = aws_s3_bucket.main_bucket.arn
    region = aws_s3_bucket.main_bucket.region
  }
}

output "bucket_url" {
  description = "URL del bucket"
  value       = "https://${aws_s3_bucket.main_bucket.bucket}.s3.${var.region}.amazonaws.com"
}
```

### 🧪 Experimentos
- Sube un archivo al bucket desde la consola AWS
- Prueba diferentes prefijos de bucket
- Observa cómo el nombre es único automáticamente

---

## 🔒 Ejercicio 3: Security Group (Firewall)

### Objetivo
Configurar reglas de firewall para controlar el tráfico.

**1. Variables (`variables.tf`):**
```hcl
variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "sg_name" {
  description = "Nombre del Security Group"
  type        = string
  default     = "web-server-sg"
}

variable "allowed_ports" {
  description = "Puertos permitidos"
  type        = list(number)
  default     = [22, 80, 443]
}
```

**2. Configuración principal (`main.tf`):**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Obtener la VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Crear Security Group
resource "aws_security_group" "web_sg" {
  name_prefix = "${var.sg_name}-"
  description = "Security group para servidor web"
  vpc_id      = data.aws_vpc.default.id

  # Reglas de entrada dinámicas
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

  # Regla de salida (permitir todo)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name      = var.sg_name
    Project   = "terraform-learning"
    CreatedBy = "terraform"
  }
}
```

**3. Outputs (`outputs.tf`):**
```hcl
output "security_group_info" {
  description = "Información del Security Group"
  value = {
    id          = aws_security_group.web_sg.id
    name        = aws_security_group.web_sg.name
    description = aws_security_group.web_sg.description
    vpc_id      = aws_security_group.web_sg.vpc_id
  }
}

output "allowed_ports" {
  description = "Puertos permitidos en el Security Group"
  value       = var.allowed_ports
}
```

### 🧪 Experimentos
- Añade el puerto 8080 a la lista de puertos permitidos
- Observa cómo se crean las reglas dinámicamente
- Revisa el Security Group en la consola AWS

---

## 🗄️ Ejercicio 4: Base de Datos RDS

### Objetivo
Crear una base de datos gestionada en AWS.

**1. Variables (`variables.tf`):**
```hcl
variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "mibasededatos"
}

variable "db_username" {
  description = "Usuario administrador de la BD"
  type        = string
  default     = "admin"
}

variable "environment" {
  description = "Entorno"
  type        = string
  default     = "dev"
}
```

**2. Configuración principal (`main.tf`):**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Generar contraseña aleatoria
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Obtener VPC por defecto
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

# Crear DB subnet group
resource "aws_db_subnet_group" "main" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name        = "${var.db_name} DB subnet group"
    Environment = var.environment
  }
}

# Crear Security Group para RDS
resource "aws_security_group" "rds_sg" {
  name_prefix = "${var.db_name}-rds-"
  description = "Security group for RDS database"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
    description = "MySQL access from VPC"
  }

  tags = {
    Name        = "${var.db_name}-rds-sg"
    Environment = var.environment
  }
}

# Crear instancia RDS
resource "aws_db_instance" "main_db" {
  identifier                = "${var.db_name}-${var.environment}"
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
    Name        = "${var.db_name} Database"
    Environment = var.environment
    Project     = "terraform-learning"
    CreatedBy   = "terraform"
  }
}
```

**3. Outputs (`outputs.tf`):**
```hcl
output "database_info" {
  description = "Información de la base de datos"
  value = {
    endpoint = aws_db_instance.main_db.endpoint
    port     = aws_db_instance.main_db.port
    username = aws_db_instance.main_db.username
    db_name  = aws_db_instance.main_db.db_name
  }
}

output "connection_string" {
  description = "String de conexión a la base de datos"
  value       = "mysql://${aws_db_instance.main_db.username}:[PASSWORD]@${aws_db_instance.main_db.endpoint}:${aws_db_instance.main_db.port}/${aws_db_instance.main_db.db_name}"
  sensitive   = false
}

output "database_password" {
  description = "Contraseña de la base de datos"
  value       = random_password.db_password.result
  sensitive   = true
}
```

### 🧪 Experimentos
- Conecta a la base de datos usando las credenciales generadas
- Observa cómo se crea automáticamente el subnet group
- Revisa los backups automáticos configurados

---

## 🏗️ Ejercicio Bonus: Proyecto Completo

### Objetivo
Combinar todos los recursos en un proyecto integrado.

**Crea un archivo `complete-infrastructure.tf`:**
```hcl
# EC2 con Security Group
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Servidor creado con Terraform</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name    = "Web Server"
    Project = "complete-infrastructure"
  }
}

# Outputs del proyecto completo
output "project_summary" {
  description = "Resumen del proyecto completo"
  value = {
    web_server_ip = aws_instance.web_server.public_ip
    s3_bucket     = aws_s3_bucket.main_bucket.bucket
    database_endpoint = aws_db_instance.main_db.endpoint
    security_group = aws_security_group.web_sg.id
  }
}
```

---

## 💰 Importante: Limpieza de Recursos

**SIEMPRE ejecuta esto al terminar:**
```bash
terraform destroy
```

Esto eliminará todos los recursos y evitará costos innecesarios.

## 📚 Conceptos Aprendidos

- **Provider AWS**: Configuración y credenciales
- **Data sources**: Obtener información existente (AMI, VPC)
- **Resources**: Crear infraestructura (EC2, S3, RDS)
- **Random resources**: Generar valores únicos
- **Dynamic blocks**: Crear reglas dinámicamente
- **Outputs**: Mostrar información importante
- **Tags**: Organizar y gestionar recursos

## 🏆 Buenas Prácticas Aplicadas

1. **Usar data sources** para AMIs y VPCs por defecto
2. **Generar nombres únicos** automáticamente
3. **Configurar seguridad** por defecto (S3 privado, RDS seguro)
4. **Tags consistentes** para organización
5. **Outputs informativos** para seguimiento
6. **Contraseñas seguras** generadas automáticamente

## 🚀 Próximos Pasos

En el siguiente laboratorio trabajaremos con:
- Módulos reutilizables
- Multiple environments (dev/staging/prod)
- Remote state con S3
- CI/CD con Terraform