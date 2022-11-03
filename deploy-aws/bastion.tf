resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "private_key" {
  key_name = var.global_prefix
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "cert.pem"
}

resource "null_resource" "private_key_permissions" {
  depends_on = [local_file.private_key]
  provisioner "local-exec" {
    command = "chmod 600 cert.pem"
    interpreter = ["bash", "-c"]
    on_failure  = continue
  }
}

data "aws_ami" "amazon_linux_2" {
 most_recent = true
 owners = ["amazon"]
 filter {
   name = "owner-alias"
   values = ["amazon"]
 }
 filter {
   name = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

resource "aws_instance" "bastion_host" {
  depends_on = [aws_msk_cluster.kafka]
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.private_key.key_name
  subnet_id = aws_subnet.bastion_host_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_host.id]
  user_data = templatefile("bastion.tftpl", {
    bootstrap_server_1 = split(",", aws_msk_cluster.kafka.bootstrap_brokers)[0]
    bootstrap_server_2 = split(",", aws_msk_cluster.kafka.bootstrap_brokers)[1]
    bootstrap_server_3 = split(",", aws_msk_cluster.kafka.bootstrap_brokers)[2]
  })
  root_block_device {
    volume_type = "gp2"
    volume_size = 100
  }
  tags = {
    Name = "${var.global_prefix}-bastion-host"
  }
}

output "execute_this_to_access_the_bastion_host" {
    value = "ssh ec2-user@${aws_instance.bastion_host.public_ip} -i cert.pem"
}
