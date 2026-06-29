output "control_node_public_ip" {
  description = "Public IP of the Ansible Control Node"
  value       = aws_instance.control_node.public_ip
}

output "control_node_public_dns" {
  description = "Public DNS of the Ansible Control Node"
  value       = aws_instance.control_node.public_dns
}

output "worker_node_public_ips" {
  description = "Public IPs of Worker Nodes"
  value       = aws_instance.worker_nodes[*].public_ip
}

output "worker_node_public_dns" {
  description = "Public DNS of Worker Nodes"
  value       = aws_instance.worker_nodes[*].public_dns
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "security_group_id" {
  value = aws_security_group.main.id
}