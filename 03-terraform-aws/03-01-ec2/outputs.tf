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