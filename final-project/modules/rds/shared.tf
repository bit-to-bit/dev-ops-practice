resource "aws_db_subnet_group" "this" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.db_name}-subnet-group"
  }
}

resource "aws_security_group" "this" {
  name        = "${var.db_name}-sg"
  description = "Security group for database"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow DB access"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.db_name}-sg"
  }
}

resource "aws_db_parameter_group" "this" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.db_name}-pg"
  family = var.parameter_group_family

  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "work_mem"
    value = "4096"
  }
}

resource "aws_rds_cluster_parameter_group" "this" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.db_name}-cluster-pg"
  family = var.parameter_group_family

  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "work_mem"
    value = "4096"
  }
}
