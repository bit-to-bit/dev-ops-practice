resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${var.db_name}-cluster"
  engine             = var.engine
  engine_version     = var.engine_version
  database_name      = var.db_name
  master_username    = var.username
  master_password    = var.password
  port               = var.db_port

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name
  skip_final_snapshot             = true

  tags = {
    Name = "${var.db_name}-cluster"
  }
}

resource "aws_rds_cluster_instance" "this" {
  count = var.use_aurora ? 1 : 0

  identifier           = "${var.db_name}-instance-writer"
  cluster_identifier   = aws_rds_cluster.this[0].id
  instance_class       = var.instance_class
  engine               = aws_rds_cluster.this[0].engine
  engine_version       = aws_rds_cluster.this[0].engine_version
  db_subnet_group_name = aws_db_subnet_group.this.name

  tags = {
    Name = "${var.db_name}-instance-writer"
  }
}
