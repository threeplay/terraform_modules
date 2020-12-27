provider "aws" {
  region = var.region
}

resource "aws_instance" "bastion" {
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.bastion_instance_size
  subnet_id = var.subnet_id
  key_name = aws_key_pair.bastion_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "Bastion"
    Environment = var.environment
  }

  volume_tags = {
    Name = "Bastion storage"
    Environment = var.environment
  }
}

resource "aws_security_group" "bastion_sg" {
  name = "Bastion Security Group"
  description = "Bastion Limited Access Security Group"
  tags = {
    Name = "Bastion"
    Creator = "terraform"
    Environment = var.environment
    Visibility = "public"
  }
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ssh_ingress_ips
    content {
      protocol = "tcp"
      from_port = 22
      to_port = 22
      cidr_blocks = ["${ingress.value}/32"]
      description = "SSH Access"
    }
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "VPN Over HTTPS Access"
  }

  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    self = true
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ebs_volume" "bastion_state" {
  availability_zone = aws_instance.bastion.availability_zone
  type = "gp2"
  size = 1

  tags = {
    Name = "Bastion state"
    Environment = var.environment
  }
}

resource "aws_volume_attachment" "bastion_state" {
  device_name = "/dev/sdk"
  instance_id = aws_instance.bastion.id
  volume_id = aws_ebs_volume.bastion_state.id
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  owners = ["amazon"]
  name_regex = "amzn2-ami-hvm.+"
}

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name = "bastion_key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}
