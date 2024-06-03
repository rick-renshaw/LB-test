output "instance" {
  value = aws_instance.nginx.id
}

output "instance_ip" {
  value = aws_instance.nginx.private_ip
}

output "lb_url" {
  value = aws_lb.lbtest.dns_name
}