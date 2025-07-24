resource "aws_db_instance" "db" {
  identifier              = var.identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_encrypted       = false
  publicly_accessible     = true
  db_name                 = var.db_name
  username                = var.username
  port                    = var.port
  password                = var.password
  vpc_security_group_ids  = [aws_security_group.strapi-sg.id]
  tags                    = var.tags
  deletion_protection     = var.deletion_protection
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "strapi-sg" {
  name        = "${var.identifier}-sg"
  description = "${var.identifier}-sg"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = var.allowed_ssh_cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value["from_port"]
      to_port     = egress.value["to_port"]
      protocol    = egress.value["protocol"]
      cidr_blocks = var.allowed_ssh_cidr_blocks
    }
  }

  tags = {
    Name = "${var.identifier}-sg"
  }
}