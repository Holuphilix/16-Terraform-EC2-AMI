provider "aws" {
  region = "us-east-1" # Change this if using another region
}

# Find the latest Amazon Linux 2 AMI automatically
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]  # Official Amazon AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Automatically find the default VPC
data "aws_vpc" "default" {
  default = true
}

# Create a new key pair (Ensure you have an SSH public key)
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform_key"
  public_key = file("C:/Users/oluph/.ssh/id_rsa.pub") # Ensure this file exists
}

# Create Security Group for SSH access in the default VPC
resource "aws_security_group" "ssh_sec_group" {
  name        = "ssh-sec-group"
  description = "Allow inbound SSH traffic"
  vpc_id      = data.aws_vpc.default.id  

  ingress {
    from_port   = 22    
    to_port     = 22    
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (consider restricting to your IP)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 Instance (Primary)
resource "aws_instance" "primary_instance" {
  ami                    = data.aws_ami.latest_amazon_linux.id # Fetch latest Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraform_key.key_name # Use the created key pair
  vpc_security_group_ids = [aws_security_group.ssh_sec_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "terraform_MINI"
  }
}

# Ensure a small wait time before creating the AMI
resource "time_sleep" "wait_for_instance" {
  depends_on      = [aws_instance.primary_instance]
  create_duration = "30s"  # Adjust as needed to allow instance startup
}

# Create an additional EC2 Instance with different type
resource "aws_instance" "additional_instance" {
  ami                    = "ami-014d544cfef21b42d"  # Replace with a valid AMI ID for us-east-1
  instance_type          = "t2.small"
  key_name               = aws_key_pair.terraform_key.key_name # Use the created key pair
  vpc_security_group_ids = [aws_security_group.ssh_sec_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "Additional_Instance"
  }
}

# Create an AMI from the primary EC2 instance
resource "aws_ami_from_instance" "my_ami" {
  name               = "my-instance-ami-${formatdate("YYYYMMDD-HHmm", timestamp())}"  # Properly formatted timestamp
  source_instance_id = aws_instance.primary_instance.id
  depends_on         = [time_sleep.wait_for_instance]  # Ensures instance is fully ready

  tags = {
    Name = "terraform_AMI"
  }
}
