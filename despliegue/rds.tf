resource "aws_db_subnet_group" "demo" {
  name       = "demo-db-subnet-group-v2"
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = {
    Name = "demo-db-subnet-group-v2"
  }
}

resource "aws_security_group" "rds" {
  name        = "demo-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
    description     = "Access from ECS tasks"
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Access from anywhere for development"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "demo-rds-sg"
  }
}

resource "aws_db_instance" "demo" {
  identifier           = "demo-postgres"
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp2"
  username            = "postgres"
  password            = "demo123456"
  skip_final_snapshot = true
  publicly_accessible = true

  db_subnet_group_name   = aws_db_subnet_group.demo.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = {
    Name = "demo-postgres"
  }
} 