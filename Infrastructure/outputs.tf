output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.zvit_plus.id
}

output "public_ip" {
  description = "EC2 Public IP address"
  value       = aws_instance.zvit_plus.public_ip
}

output "private_ip" {
  description = "EC2 Private IP address"
  value       = aws_instance.zvit_plus.private_ip
}

output "instance_type" {
  description = "EC2 Instance Type"
  value       = aws_instance.zvit_plus.instance_type
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.zvit_plus.id
}