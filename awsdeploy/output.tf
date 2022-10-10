output "lb-hostname" {
  description = "Hostname of the load balancer"
  value = aws_alb.application_load_balancer.dns_name
}
