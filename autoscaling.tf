data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "my_aws_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
  
  tags = {
      Name = "${var.ENVIRONMENT}-app-ssh-key"
  }
}

# >> Autoscaling template for launching the EC2 instances
resource "aws_launch_configuration" "app-launch-config" {
  name = "app-launch-configuration"
  image_id = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.ssh-key.key_name
  security_groups = [aws_security_group.app-instance-sg.id]
  user_data = file("elb-test.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# >> Autoscaling group of instances with similar characteristics
resource "aws_autoscaling_group" "app-group-autoscaling" {
  name = "app-group-autoscaling"
  vpc_zone_identifier = ["subnet-02dbbce28159f9243", "subnet-05c213c938a29bdce"]
  # name of launch config template
  launch_configuration = aws_launch_configuration.app-launch-config.name
  # min size of auto scaling group
  min_size = 2
  # max size of autoscaling group
  max_size = 4 
  # time in sec after instance comes into service before checking health
  health_check_grace_period = 100
  # EC2 or ELB controls how health checking is done  
  health_check_type = "ELB"
  # Allows deleting the autoscaling group without waiting all instances in the pool to terminate
  force_delete = true

  load_balancers = [aws_elb.app-elb.name]
  tag {
      key = "name"
      value = "${var.ENVIRONMENT}-app-ec2-instance"
      # enable propagation of the tag to EC2 launched via ASG
      propagate_at_launch = true
  }  
}



# >> Autoscaling policy
resource "aws_autoscaling_policy" "app-cpu-policy" {
  name = "app-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.app-group-autoscaling.name
  # Specifies whether the adjustment is an absolute num or a percentage of the current capacity
  adjustment_type = "ChangeInCapacity"
  # number of instanced by which to scale
  scaling_adjustment = 1
  # the amount of time in sec after the scaling activity complete & before the next one start
  cooldown = 300
  policy_type = "SimpleScaling"
}