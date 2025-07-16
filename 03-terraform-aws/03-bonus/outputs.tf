output "project_summary" {
  description = "Resumen completo del proyecto"
  value = {
    project_name     = var.project_name
    environment      = var.environment
    web_server_ip    = aws_instance.web_server.public_ip
    web_server_url   = "http://${aws_instance.web_server.public_ip}"
    s3_bucket_name   = aws_s3_bucket.app_bucket.bucket
    database_endpoint = aws_db_instance.app_db.endpoint
  }
}

output "connection_info" {
  description = "Información de conexión"
  value = {
    web_server = {
      public_ip  = aws_instance.web_server.public_ip
      private_ip = aws_instance.web_server.private_ip
      ssh_command = "ssh -i tu-clave.pem ec2-user@${aws_instance.web_server.public_ip}"
    }
    
    database = {
      endpoint = aws_db_instance.app_db.endpoint
      port     = aws_db_instance.app_db.port
      username = aws_db_instance.app_db.username
      database = aws_db_instance.app_db.db_name
    }
    
    storage = {
      bucket_name = aws_s3_bucket.app_bucket.bucket
      bucket_arn  = aws_s3_bucket.app_bucket.arn
    }
  }
}

output "security_groups" {
  description = "IDs de los Security Groups"
  value = {
    web_sg = aws_security_group.web_sg.id
    rds_sg = aws_security_group.rds_sg.id
  }
}

output "database_password" {
  description = "Contraseña de la base de datos (sensible)"
  value       = random_password.db_password.result
  sensitive   = true
}

output "next_steps" {
  description = "Próximos pasos recomendados"
  value = [
    "1. Visita http://${aws_instance.web_server.public_ip} para ver tu aplicación",
    "2. Conéctate a la base de datos usando las credenciales en 'database_password'",
    "3. Sube archivos al bucket S3: ${aws_s3_bucket.app_bucket.bucket}",
    "4. Recuerda ejecutar 'terraform destroy' cuando termines para evitar costos"
  ]
}