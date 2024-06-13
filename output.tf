output "loadBalancerDNS" {
  value = aws_lb.myalb.dns_name
}