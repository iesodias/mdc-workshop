output "instance_public_ip" {
  value = aws_instance.web.public_ip
  description = "The public IP address of the web instance."
}