terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "vle8_server" {
  ami                    = "ami-02a9cdd4e98bc3c78"
  instance_type          = "t3.xlarge"
  key_name               = "devsecops-key"
  subnet_id              = "subnet-0af2d32a3bf6faf88"
  vpc_security_group_ids = ["sg-00193b232ce5fd5a2"]

  iam_instance_profile = "VLE8-Terraform-Role"

  associate_public_ip_address = true

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "VLE8-BlueGreen-Server"
  }

  lifecycle {
    prevent_destroy = true
  }
}
