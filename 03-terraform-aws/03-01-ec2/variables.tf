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