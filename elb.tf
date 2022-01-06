# >> AWS ELB config
resource "aws_elb" "app-elb" {
  name = "app-elb"
  subnets = [aws_subnet.app-public-sub-1-a.id,aws_subnet.app-public-sub-2-b.id]
  security_groups = [aws_security_group.app-elb-sg.id] 

  listener {
      instance_port = 80
      instance_protocol = "http"
      lb_port = 80
      lb_protocol = "http"
  }   


  health_check {
      # number of checks before instance is declared healthy
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      target = "HTTP:80/"
      interval = 30
  }

  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400

  tags = {
      Name = "${var.ENVIRONMENT}-app-elb"
  }
}

# >> Security group for AWS ELB 
resource "aws_security_group" "app-elb-sg" {
    vpc_id = aws_vpc.app-vpc.id
    name = "app-elb-sg"
    description = "Security group for ELB"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.ENVIRONMENT}-app-elb-sg"
    }
}

# >> Security group for instances
resource "aws_security_group" "app-instance-sg" {
    vpc_id = aws_vpc.app-vpc.id
    name = "app-instance-sg"
    description = "Security group for instances"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.app-elb-sg.id]
    }

    tags = {
        Name = "${var.ENVIRONMENT}-app-instance-sg"
    }
}