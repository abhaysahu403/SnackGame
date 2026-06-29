resource "aws_instance" "control_node" {

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/cloud-init.yaml")

  tags = {
    Name = "${var.project_name}-control-node"
    Role = "control"
  }
}

resource "aws_instance" "worker_nodes" {

  count = var.worker_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/cloud-init.yaml")

  tags = {
    Name = "${var.project_name}-worker-${count.index + 1}"
    Role = "worker"
  }
}

resource "local_file" "ansible_inventory" {

  filename = "${path.module}/../ansible/inventory.ini"

  content = templatefile("${path.module}/inventory.tpl", {

    control_ip = aws_instance.control_node.public_ip

    worker_ips = aws_instance.worker_nodes[*].public_ip

  })

}