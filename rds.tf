# >> Subnet Group : deploy db service within the region
resource "aws_db_subnet_group" "app-db" {
    name = "app-db"
    subnet_ids = [ aws_subnet.app-private-sub-1-a.id, aws_subnet.app-private-sub-2-b.id ]

    tags = {
        Name = "${var.ENVIRONMENT}-app-db"
    }
}   

# >> Parameter Group : to specify parameter to change settings in db
resource "aws_db_parameter_group" "app-db" {
  name = "app-db"
  family = "postgres10"

  parameter {
      name = "log_connections"
      value = "1"
  }
}

# >> Security Group : allow incoming traffic to rds instance
resource "aws_security_group" "app-rds-sg" {
  name = "app-rds-sg"
  description = "allow inbound access to the database"
  vpc_id      = aws_vpc.app-vpc.id

  ingress {
      protocol = "-1"
      from_port = 0
      to_port = 0
      cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [var.vpc_cidr_block]
  }
}


# >> rds instance
resource "aws_db_instance" "app-db" {
    identifier = "app-db"
    instance_class = "db.r3.large"
    storage_type = "gp2"
    allocated_storage = 256
    engine = var.db_engine
    engine_version = "13.1"
    username = var.db_username
    password = var.db_password
    db_subnet_group_name = aws_db_subnet_group.app-db.name
    vpc_security_group_ids = [ aws_security_group.app-rds-sg.id]
    parameter_group_name = aws_db_parameter_group.app-db.name
    publicly_accessible = false
    skip_final_snapshot = true
    multi_az = false
}