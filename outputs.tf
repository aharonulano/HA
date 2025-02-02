# output "load_balancer_dns" {
#   description = "DNS of the Load Balancer"
#   value       = aws_lb.nginx.dns_name
# }
#
# output "lb_zone" {
#   description = "the zone"
#   value       = aws_lb.nginx.zone_id
# }

output "public_ip" {
  value = aws_instance.nat_instance.public_ip
}

output "public_subnet_ip" {
  value = aws_subnet.public.map_public_ip_on_launch
}
