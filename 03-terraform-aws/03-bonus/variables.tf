variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "mi-app-completa"
}

variable "environment" {
  description = "Entorno (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "allowed_ports" {
  description = "Puertos permitidos en el servidor web"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Usuario administrador de la BD"
  type        = string
  default     = "admin"
}