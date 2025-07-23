

resource "aws_instance" "ec2" {
  region                     = var.aws_region
  ami                        = var.ami_id
  instance_type              = var.instance_type
  key_name                   = var.key_name
  subnet_id                  = var.subnet_id
  vpc_security_group_ids     = [aws_security_group.all_tcp.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.volume_size
  }
  user_data_base64 = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    github_username = var.github_username
    github_token    = var.github_token
    docker_hub_token = var.docker_hub_token
  }))
  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags
  )
}

resource "aws_security_group" "all_tcp" {
  name        = "strapi-sg-v2"
  region     = var.aws_region
  description = "Allow all TCP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
