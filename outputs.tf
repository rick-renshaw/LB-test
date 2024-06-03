output "instance" {
  value = aws_instance.nginx.id
}

output "lb_url" {
  value = aws_lb.lbtest.dns_name
}