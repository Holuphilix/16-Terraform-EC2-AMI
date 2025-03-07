output "instance_public_ip" {
  description = "Public IP of the created EC2 instance"
  value       = aws_instance.my_instance.public_ip
}

output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.my_instance.id
}

output "ami_id" {
  description = "ID of the created AMI"
  value       = aws_ami_from_instance.my_ami.id
}

output "security_group_id" {
  description = "ID of the security group created"
  value       = aws_security_group.ssh-sec-group.id
}

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = aws_key_pair.terraform_key.key_name
}

output "security_group_name" {
  description = "Name of the security group created"
  value       = aws_security_group.ssh-sec-group.name
}

output "instance_private_ip" {
  description = "Private IP of the created EC2 instance"
  value       = aws_instance.my_instance.private_ip
}
