resource "aws_security_group" "rds_security_group" {
  name   = "${var.project_name}-db-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [var.allowed_source_sg]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_db_subnet_group" "db_subnet_gr" {
  name       = "${var.project_name}-db-subnet"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet"
  }
}

resource "aws_db_instance" "db_instance" {
  depends_on        = [aws_security_group.rds_security_group]
  db_name           = "mydb"
  allocated_storage = 5
  engine            = var.engine_type
  engine_version    = var.engine_ver
  instance_class    = var.db_instance_type
  username          = "admin"
  password          = var.db_password
  identifier        = var.project_name

  skip_final_snapshot     = true
  multi_az                = false
  backup_retention_period = 10
  backup_window           = "22:00-23:59"

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_gr.name
}
