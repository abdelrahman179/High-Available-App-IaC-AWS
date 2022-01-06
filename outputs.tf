output "elb" {
    value = aws_elb.app-elb.dns_name
}